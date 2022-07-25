//
//  InviteVC.swift
//  Imposta
//
//  Created by Rovshen Shirinzade on 8/23/20.
//  Copyright © 2020 Imposta. All rights reserved.
//

import UIKit
import SVProgressHUD
import MarqueeLabel

class InviteVC: UIViewController {

    @IBOutlet weak var accountNameLbl: MarqueeLabel!
    @IBOutlet weak var emailTF: TFLRPadding10!
    @IBOutlet weak var onLogoIcon: UIImageView!
    
    @IBOutlet weak var logoutIcon: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLogo()
        
        accountNameLbl.type = .continuous
        accountNameLbl.animationCurve = .easeInOut
        accountNameLbl.fadeLength = 10.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        accountNameLbl.text = UserDefaultsHelper.shared.getClientName()
    }
    
    @IBAction func sendBtnAction(_ sender: UIButton) {
        if let email = emailTF.text, email.isValidEmail() {
            SVProgressHUD.show()
            ProfileApi.shared.sendInvitation(email: email) { response in
                SVProgressHUD.dismiss()
                self.alertWithHandler(title: "SUCCESS", message: "Invitation has sent", actionButton: "OK") {
                    self.emailTF.text = ""
                    self.emailTF.resignFirstResponder()
                }
                } failure: { error in
                    SVProgressHUD.dismiss()
                    self.alert(title: "ERROR", message: "Invitation hasn't sent", actionButton: "OK")
                }
                
            }
            else {
                alert(title: "WARNING", message: "Please enter email address", actionButton: "OK")
            }

//            ClientApi.shared.sendInvitaion(email: email, success: {
//                SVProgressHUD.dismiss()
//                self.alertWithHandler(title: "SUCCESS", message: "Invitation has sent", actionButton: "OK") {
//                    self.emailTF.text = ""
//                    self.emailTF.resignFirstResponder()
//                }
//            }, failure: {
//                SVProgressHUD.dismiss()
//                self.alert(title: "ERROR", message: "Invitation hasn't sent", actionButton: "OK")
//            })
//        } else {
//            alert(title: "WARNING", message: "Please enter email address", actionButton: "OK")
//        }
    }
    
    @IBAction func showAccountsAction(_ sender: UIButton) {
        if let VC = R.storyboard.client.accountsVC() {
            SVProgressHUD.show()
            
            AppApi.shared.getAllAccountNew { response in
                if let clients = response as? [AccountOnHeaderElement] {
                    VC.arrUserNew = clients
                    VC.delegate = self
                    let showPopup = SBCardPopupViewController(contentViewController: VC)
                    showPopup.show(onViewController: self)
                    SVProgressHUD.dismiss()
                }
            } failure: {
                SVProgressHUD.dismiss()
            }
            
//            AppApi.shared.getAllAccount(success: { response in
//                guard let clients = response.result else { return }
//                VC.arrUser = clients
//                VC.delegate = self
//                let showPopup = SBCardPopupViewController(contentViewController: VC)
//                showPopup.show(onViewController: self)
//                SVProgressHUD.dismiss()
//            }, failure: {
//                SVProgressHUD.dismiss()
//            })
        }
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension InviteVC: SelectAccount {
    func selectAccount(_: Bool) {
        accountNameLbl.text = UserDefaultsHelper.shared.getClientName()
    }
    
    func setupLogo() {
        onLogoIcon.isUserInteractionEnabled = true
        onLogoIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onHome)))
//        setLogout(view: logoutIcon)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onLogout))
                self.logoutIcon.isUserInteractionEnabled = true
                self.logoutIcon.addGestureRecognizer(gesture)
    }
    
    @objc func onLogout() {
                print(#function)
                ProfileApi.shared.logoutProfile { result in
                    print(result)
                }
            let appDelegate = AppDelegate()
            appDelegate.setRoot()
    //        setLogout(view: logoutIcon)
            print("gestured used")
        }
}

