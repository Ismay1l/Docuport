//
//  ClientVC.swift
//  Imposta
//
//  Created by Shamkhal Guliyev on 9/3/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit
import SVProgressHUD

class ClientVC: UIViewController {
    @IBOutlet var tableClient: UITableView!
    @IBOutlet var buttonAdd: UIButton!
    @IBOutlet var viewUserEmail: UIView!
    @IBOutlet var txtFieldEmail: UITextField!
    @IBOutlet var imgInvalidEmail: UIImageView!
    @IBOutlet weak var viewUserEmailBottomConstraint: NSLayoutConstraint!
    
    var isFinish = false, isSearch = false
    
    var keyboardHeight: CGFloat?
    var searchedClient: ClientSearch?
    var arrClient = [ResultClients]()
    var arrClientNew = [Item]()
    var arrClientCopy = [ResultClients]()    
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func setup() {
        searchedClient = ClientSearch()
        searchType = .clients
        
//        getClientList()
//        getClientListNew()
        addMenuNavButton()
        
        viewUserEmail.layer.borderWidth = 2
        viewUserEmail.layer.borderColor = UIColor(hexStr: "3AB886", colorAlpha: 1).cgColor
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableClient.addSubview(refreshControl)
    }
    
    @objc func refresh() {
        arrClient.removeAll()
        tableClient.reloadData()
//        getClientList()
//        getClientListNew()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            if DeviceType.shared.isIphone6() {
                viewUserEmailBottomConstraint.constant = keyboardHeight!
            } else {
                viewUserEmailBottomConstraint.constant = keyboardHeight!-30
            }
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
//    func getClientListNew() {
//        SVProgressHUD.show()
//        ClientApi.shared.getClientListNew { response in
//            if response.totalCount == 0 {
//                self.isFinish = true
//            }
//            else {
//                self.isFinish = false
//                if let result = response as? ClientList {
//                    for client in result {
//                        self.arrClientNew.append(client)
//                    }
//                    self.tableClient.reloadData()
//                }
//                SVProgressHUD.dismiss()
//                self.refreshControl.endRefreshing()
//            }
//        } failure: {
//            SVProgressHUD.dismiss()
//            self.refreshControl.endRefreshing()
//        }
//
//    }

    
    func getClientList() {
        SVProgressHUD.show()
        ClientApi.shared.getClientList(limit: 20, offset: arrClient.count, success: { response in
            if response.result?.clients?.count == 0 {
                self.isFinish = true
            } else {
                self.isFinish = false
                guard let result = response.result else { return }
                
                for client in (result.clients)! {
                    self.arrClient.append(client)
                }
                self.tableClient.reloadData()
            }
            SVProgressHUD.dismiss()
            self.refreshControl.endRefreshing()
        }, failure: {
            SVProgressHUD.dismiss()
            self.refreshControl.endRefreshing()
        })
    }
    
    func closeEmailView() {
        txtFieldEmail.text = ""
        viewUserEmail.isHidden = true
        imgInvalidEmail.isHidden = true
        txtFieldEmail.textColor = .black
        txtFieldEmail.resignFirstResponder()
        viewUserEmailBottomConstraint.constant = 20
    }
    
    @IBAction func btnAddClient(_ sender: Any) {
        viewUserEmail.isHidden = false
    }
    
    @IBAction func btnSearch(_ sender: Any) {
        let clientSearchVC = getVC(id: "ClientSearchVC") as! ClientSearchVC
        clientSearchVC.delegate = self
        clientSearchVC.clientSearch = searchedClient
        customPresentViewController(presenter, viewController: clientSearchVC, animated: true)
    }
    
    @IBAction func btnCancelAddClient(_ sender: Any) {
        closeEmailView()
    }
    
    @IBAction func btnSendMailAddress(_ sender: Any) {
        if txtFieldEmail.text?.count == 0 {
            alert(title: "WARNING", message: "Please enter email address", actionButton: "OK")
        } else {
            if isValidEmail(txtFieldEmail.text!) {
                SVProgressHUD.show()
                ClientApi.shared.sendInvitaion(email: txtFieldEmail.text!, success: {
                    self.closeEmailView()
                    self.alert(title: "SUCCESS", message: "Invitation has sent", actionButton: "OK")
                    SVProgressHUD.dismiss()
                }, failure: {
                    SVProgressHUD.dismiss()
                    self.alert(title: "ERROR", message: "Invitation hasn't sent", actionButton: "OK")
                })
                imgInvalidEmail.isHidden = true
                txtFieldEmail.textColor = .black
            } else {
                imgInvalidEmail.isHidden = false
                txtFieldEmail.textColor = UIColor(hexStr: "E15151", colorAlpha: 1)
            }
        }
    }
}

extension ClientVC: ClientSearchDelegate {
    func clientSearchReset() {
        isSearch = false
        searchedClient = ClientSearch()
        arrClient.removeAll()
        getClientList()
    }
    
    func clientSearchResult(clientSearch: ClientSearch) {
        isSearch = true
        arrClient.removeAll()
        searchedClient = clientSearch
        SVProgressHUD.show()
        ClientApi.shared.getSearchedClient(limit: 50, offset: arrClient.count, clientSearch: clientSearch, success: { response in
            if response.result?.clients?.count == 0 {
                self.isFinish = true
            } else {
                self.isFinish = false
                for client in (response.result?.clients)! {
                    self.arrClient.append(client)
                }
            }
            SVProgressHUD.dismiss()
            self.tableClient.reloadData()
        }, failure: {
            SVProgressHUD.dismiss()
        })
    }
}

extension ClientVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        viewUserEmailBottomConstraint.constant = 20
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            if updatedText.isEmpty {
                imgInvalidEmail.isHidden = true
                txtFieldEmail.textColor = .black
            }
        }
        
        return true
    }
}

extension ClientVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrClient.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClientCell") as! ClientCell
        
        if arrClientNew[indexPath.row].clientType == Int(ClientType.Personal.rawValue) {
            cell.imgClient.image = UIImage(named: "personal")
            cell.lblAccount.text = arrClientNew[indexPath.row].fullName
        } else {            
            cell.imgClient.image = UIImage(named: "business")
            cell.lblAccount.text = arrClientNew[indexPath.row].name
        }
        
        cell.lblClientId.text = arrClientNew[indexPath.row].phoneNumber
//        if arrClientNew[indexPath.row].services.count ?? 0 > 0 {
//            cell.lblService.text = arrClientNew[indexPath.row].services[0]
//        } else {
//            cell.lblService.text = ""
//        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let clientDetailVC = getVC(id: "ClientDetailVC") as! ClientDetailVC
        clientDetailVC.client = arrClient[indexPath.row]
        
        let clientDetailNav = getNav(id: "clientDetailNav")
        clientDetailNav.viewControllers = [clientDetailVC]
        customPresentViewController(presenter, viewController: clientDetailNav, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !isFinish {
            if indexPath.row == arrClientNew.count - 1 {
                if !isSearch {
//                    getClientListNew()
                }
            }
        }
    }
}
