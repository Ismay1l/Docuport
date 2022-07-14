//
//  InvitationsVC.swift
//  Imposta
//
//  Created by Shamkhal Guliyev on 9/13/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit
import SVProgressHUD

class InvitationsVC: UIViewController {    
    @IBOutlet var tableInvitations: UITableView!
    @IBOutlet var viewUserEmail: UIView!
    @IBOutlet var txtFieldEmail: UITextField!
    @IBOutlet var imgInvalidEmail: UIImageView!
    @IBOutlet weak var bottomContraintEmailView: NSLayoutConstraint!
    
    var keyboardHeight: CGFloat?
    var isFinish = false
    var status: String?
    var recipient: String?
    var arrInvitation = [Invitations]()
    var arrInvitationCopy = [Invitations]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            if DeviceType.shared.isIphone6() {
                bottomContraintEmailView.constant = keyboardHeight!
            } else {
                bottomContraintEmailView.constant = keyboardHeight!-30
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        bottomContraintEmailView.constant = 0
    }
    
    func setup() {
        searchType = .invitations
        viewUserEmail.layer.borderWidth = 2
        viewUserEmail.layer.borderColor = UIColor(hexStr: "3AB886", colorAlpha: 1).cgColor
        txtFieldEmail.delegate = self
        
        addMenuNavButton()
        getInvivations()
        
        let menuButton = UIBarButtonItem(image: UIImage(named: "search"), style: .plain, target: self, action: #selector(openDocSearch))
        menuButton.tintColor = UIColor(hexStr: "44BA8B", colorAlpha: 1)
        self.navigationItem.rightBarButtonItem = menuButton
    }
    
    @objc func openDocSearch() {
        let vc = getVC(id: "InvitationSearchVC") as! InvitationSearchVC
        vc.delegate = self
        customPresentViewController(presenter, viewController: vc, animated: true)
    }
    
    func getInvivations() {
        SVProgressHUD.show()
        ClientApi.shared.getInvitations(limit: 20, offset: arrInvitation.count, recipient: recipient ?? "", status: status ?? "", success: { response in
            guard let invitations = response.result?.invitations else { return }
            
            if invitations.count == 0 {
                self.isFinish = true
            } else {
                self.isFinish = false
                for invitation in invitations {
                    self.arrInvitation.append(invitation)
                }
                self.arrInvitationCopy = self.arrInvitation
                self.tableInvitations.reloadData()
            }
            SVProgressHUD.dismiss()
        }, failure: { errorMessage in
            self.alert(title: "ERROR", message: errorMessage, actionButton: "OK")
            SVProgressHUD.dismiss()
        })
    }
    
    func closeEmailView() {
        txtFieldEmail.text = ""
        viewUserEmail.isHidden = true
        imgInvalidEmail.isHidden = true
        txtFieldEmail.textColor = .black
        txtFieldEmail.resignFirstResponder()
        bottomContraintEmailView.constant = 20
    }
    
    func filterSearch(_ text: String) {
        arrInvitation.removeAll()
        if text == "All" {
            arrInvitation = arrInvitationCopy
        } else {
            arrInvitation = arrInvitationCopy.filter { $0.status!.contains(text) || $0.recipient!.contains(text) }
        }
        isFinish = true
        tableInvitations.reloadData()
    }
    
    @IBAction func btnClose(_ sender: Any) {
        closeEmailView()
    }
    
    @IBAction func btnSend(_ sender: Any) {
        if txtFieldEmail.text?.count == 0 {
            alert(title: "WARNING", message: "Please enter email address", actionButton: "OK")
        } else {
            if isValidEmail(txtFieldEmail.text!) {
                SVProgressHUD.show()
                ClientApi.shared.sendInvitaion(email: txtFieldEmail.text!, success: {
                    SVProgressHUD.dismiss()
                    self.closeEmailView()
                    self.alertWithHandler(title: "SUCCESS", message: "Invitation has sent", actionButton: "OK") {
                        self.arrInvitation.removeAll()
                        self.getInvivations()
                    }
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
    
    @IBAction func btnPlus(_ sender: Any) {
        viewUserEmail.isHidden = false
    }
}

extension InvitationsVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

extension InvitationsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrInvitation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InvitationCell") as! InvitationCell
        
        cell.lblEmail.text = arrInvitation[indexPath.row].recipient
        cell.lblAccount.text = arrInvitation[indexPath.row].client?.name
        
        if arrInvitation[indexPath.row].status == InvitationType.sent.rawValue { //red
            cell.viewSideColor.backgroundColor = UIColor(hexStr: "E15151", colorAlpha: 1)
            
        } else if arrInvitation[indexPath.row].status == InvitationType.received.rawValue { //gray
            cell.viewSideColor.backgroundColor = UIColor(hexStr: "969696", colorAlpha: 1)
            
        } else if arrInvitation[indexPath.row].status == InvitationType.registered.rawValue { //green
            cell.viewSideColor.backgroundColor = UIColor(hexStr: "63D66B", colorAlpha: 1)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !isFinish {
            if indexPath.row == arrInvitation.count - 1 {
                getInvivations()
            }
        }
    }
}

extension InvitationsVC: InvitationSearchDelegate {
    func didSegmentSelected(type: Invitaion) {
        filterSearch(type.rawValue)
    }
    
    func invitationSearchResult(text: String) {
        filterSearch(text)
    }
    
    func reset() {
        filterSearch("All")
    }
}
