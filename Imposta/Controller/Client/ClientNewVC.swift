//
//  ClientNewVC.swift
//  Imposta
//
//  Created by Rovshen Shirinzade on 8/23/20.
//  Copyright © 2020 Imposta. All rights reserved.
//

import UIKit
import SVProgressHUD

class ClientNewVC: UIViewController {

    @IBOutlet weak var topView: CardView!
    @IBOutlet weak var addButtonView: CardView!
    @IBOutlet weak var emailView: CardView!
    @IBOutlet weak var emailViewWidth: NSLayoutConstraint!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var alertView: CardView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewUserEmailBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var onLogoIcon: UIImageView!
    @IBOutlet weak var onLogoutIcon: UIImageView!
    
    var isFinish = false
    var keyboardHeight: CGFloat?
    
    var arrClient = [ResultClients]()
    var refreshControl = UIRefreshControl()
    var arrClientNew = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailView.isHidden = true
        emailViewWidth.constant = 0
        alertView.isHidden = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onHome))
                self.onLogoutIcon.isUserInteractionEnabled = true
                self.onLogoutIcon.addGestureRecognizer(gesture)
        
//        onLogoIcon.isUserInteractionEnabled = true
//        onLogoIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onHome)))
//        setLogout(view: onLogoutIcon)
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
//        getClientList()
        getClientListNew()
        
        if !GetUserType.user.isUserAdvisor() {
            addButtonView.isHidden = true
        }
        
        hideKeyboardOnTap()
        NotificationCenter.default.addObserver(self, selector: #selector(editClient(notification:)), name: .editClient, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(noti:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func refresh() {
//        arrClient.removeAll()
        arrClientNew.removeAll()
        tableView.reloadData()
//        getClientList()
        getClientListNew()
    }
    
    func getClientListNew() {
        SVProgressHUD.show()
        ClientApi.shared.getClientListNew { response in
            if response.totalCount == 0 {
                self.isFinish = true
            }
            else {
                self.isFinish = false
                if let result = response as? ClientList  {
//                    print("resultWWW: \(result)")
                    for client in (result.items)! {
                        print("clientttt: \(client)")
                        self.arrClientNew.append(client)
                    }
                    self.tableView.reloadData()
                }
                SVProgressHUD.dismiss()
                self.refreshControl.endRefreshing()
            }
        } failure: {
            SVProgressHUD.dismiss()
            self.refreshControl.endRefreshing()
        }
    }
    
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
                self.tableView.reloadData()
            }
            SVProgressHUD.dismiss()
            self.refreshControl.endRefreshing()
        }, failure: {
            SVProgressHUD.dismiss()
            self.refreshControl.endRefreshing()
        })
    }

    @IBAction func addButtonAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.addButtonView.isHidden = true
            self.emailView.isHidden = false
            self.emailViewWidth.constant = self.view.bounds.size.width - 40
            self.view.layoutIfNeeded()
        })
    }

//    @IBAction func sendButtonAction(_ sender: UIButton) {
//        if let email = emailTF.text, email.count > 0 {
//            if email.isValidEmail() {
//                SVProgressHUD.show()
//                ClientApi.shared.sendInvitaion(email: email, success: {
//                    self.showAlertView()
//                    SVProgressHUD.dismiss()
//                }, failure: {
//                    SVProgressHUD.dismiss()
//                    self.alert(title: "ERROR", message: "Invitation hasn't sent", actionButton: "OK")
//                })
//            } else {
//                emailTF.textColor = .red
//            }
//        } else {
//            alert(title: "WARNING", message: "Please enter email address", actionButton: "OK")
//        }
//    }
    
    @IBAction func sendButtonAction(_ sender: UIButton) {
        if let email = emailTF.text, email.count > 0 {
            if email.isValidEmail() {
                SVProgressHUD.show()
                ProfileApi.shared.sendInvitation(email: email) { response in
                    self.showAlertView()
                    SVProgressHUD.dismiss()
                } failure: { err in
                    SVProgressHUD.dismiss()
                    self.alert(title: "ERROR", message: "Invitation hasn't sent", actionButton: "OK")
                }
                
            } else {
                emailTF.textColor = .red
            }
        } else {
            alert(title: "WARNING", message: "Please enter email address", actionButton: "OK")
        }
    }
    
    @IBAction func closeViewAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.addButtonView.isHidden = false
            self.emailViewWidth.constant = 0
            self.view.layoutIfNeeded()
        }, completion: {
            finished in
            self.emailView.isHidden = true
        })
    }
    
    func showAlertView() {
        self.alertView.alpha = 0
        self.alertView.isHidden = true
        self.emailView.isHidden = true

        UIView.animate(withDuration: 0.3, animations: {
            self.alertView.alpha = 1
            UIView.animate(withDuration: 0.3, delay: 3.0, options: [], animations: {
                self.alertView.alpha = 0
                self.addButtonView.isHidden = false
                self.emailTF.text = ""
                self.emailTF.textColor = UIColor.init(hexString: "#292929")
            })
        }, completion: {
            finished in
            self.alertView.isHidden = false
        })
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
       if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
           let keyboardRectangle = keyboardFrame.cgRectValue
           keyboardHeight = keyboardRectangle.height
           if DeviceType.shared.isIphone6() {
               viewUserEmailBottomConstraint.constant = keyboardHeight!
           } else {
               viewUserEmailBottomConstraint.constant = keyboardHeight! - 70
           }
           
           UIView.animate(withDuration: 0.3) {
               self.view.layoutIfNeeded()
           }
       }
    }
    
    @objc func keyboardWillHide(noti: Notification) {
       viewUserEmailBottomConstraint.constant = 20
    }
    
    @objc func editClient(notification: NSNotification) {
        refresh()
    }
    
}

extension ClientNewVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrClientNew.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.clientTVCell.identifier, for: indexPath) as! ClientTVCell
        cell.setup(client: arrClientNew[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SVProgressHUD.show()
        print("idWWW: \(arrClientNew[indexPath.row].id ?? 0)")
//        arrClientNew[indexPath.row].clientType
        print("typeWWW: \(arrClientNew[indexPath.row].clientType)")
        if  arrClientNew[indexPath.row].clientType == 1 {
            ClientApi.shared.getClientByIDBusiness(id: arrClientNew[indexPath.row].id ?? 0, success: { response in
                self.isFinish = false
                guard let result = response as? ClientInfoUser1 else { return }

                if let VC = R.storyboard.advisor.clientInfoVC() {
                    VC.clientBusiness = result
                    VC.clientType = result.clientType
                    let showPopup = SBCardPopupViewController(contentViewController: VC)
                    showPopup.show(onViewController: self)
                }

                self.tableView.reloadData()
                SVProgressHUD.dismiss()
            }, failure: {
                SVProgressHUD.dismiss()
            })
        } else if arrClientNew[indexPath.row].clientType == 2 {
            ClientApi.shared.getClientByIDPersonal(id: arrClientNew[indexPath.row].id ?? 0, success: { response in
                self.isFinish = false
                guard let result = response as? ClientInfoUser2 else { return }
                
                if let VC = R.storyboard.advisor.clientInfoVC() {
                    VC.clientPersonal = result
                    VC.clientType = result.clientType
                    let showPopup = SBCardPopupViewController(contentViewController: VC)
                    showPopup.show(onViewController: self)
                }

                self.tableView.reloadData()
                SVProgressHUD.dismiss()
            }, failure: {
                SVProgressHUD.dismiss()
            })
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !isFinish {
            if indexPath.row == arrClientNew.count  {
                getClientListNew()
            }
        }
    }
}
