//
//  LoginVC.swift
//  Imposta
//
//  Created by Shamkhal Guliyev on 8/29/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit
import SVProgressHUD

class LoginVC: UIViewController {
    
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var txtFieldEmail: UITextField!
    @IBOutlet weak var txtFieldPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(noti:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(noti:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        hideKeyboardOnTap()
        viewHeight.constant = UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.size.height - (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
    }
 
    @objc func keyboardWillHide(noti: Notification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillShow(noti: Notification) {
        guard let keyboardFrame = noti.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        scrollView.contentInset.bottom = view.convert(keyboardFrame.cgRectValue, from: nil).size.height
    }
    
    @IBAction func btnForgotPassword(_ sender: Any) {
        showVC(id: "ForgotPasswordVC")
    }
    
    @IBAction func btnLogin(_ sender: Any) {
        if txtFieldEmail.text?.count != 0 && txtFieldPassword.text?.count != 0 {
            SVProgressHUD.show()
            ProfileApi.shared.loginProfile(tenancyName: "", usernameOrEmail: txtFieldEmail.text!, password: txtFieldPassword.text!, success: { response in
                if UserDefaultsHelper.shared.getUserType() == UserType.Client.rawValue {
                    SVProgressHUD.show()
                    
                    AppApi.shared.getAllAccountNew { response in
                        if let clients = response as? [AccountOnHeaderElement] {
                            if let firstClient = clients.first {
                                UserDefaultsHelper.shared.setClientID(id: firstClient.id ?? 0)
                                UserDefaultsHelper.shared.setClientName(name: firstClient.name ?? "")
                            }
                            
                            if let advisor = clients.first?.advisor {
                                UserDefaults.setAccountInfoNew(advisor)
                            }
                            
//                            if clients.first?.clientType == ClientType.Business.rawValue {
//                                UserDefaultsHelper.shared.setClientName(name: clients.first?.name ?? "")
//                            } else if clients.first?.clientType == ClientType.Personal.rawValue {
//                                UserDefaultsHelper.shared.setClientName(name:  clients.first?.name ?? "")
//                            }
                            
                            self.showDashboardVC()
                            SVProgressHUD.dismiss()
                        }
                    } failure: {
                        SVProgressHUD.dismiss()
                    }

                    
//                    AppApi.shared.getAllAccount(success: { response in
//                        guard let clients = response.result else { return }
//                        UserDefaultsHelper.shared.setClientID(id: clients[0].id ?? 0)
//                        UserDefaultsHelper.shared.setClientName(name: clients.first?.fullClientName ?? "")
//                        if let advisor = clients.first?.advisor {
//                            UserDefaults.setAccountInfo(advisor)
//                        }
//
//                        if clients.first?.clientType == ClientType.Business.rawValue {
//                            UserDefaultsHelper.shared.setClientName(name: clients.first?.name ?? "")
//                        } else if clients.first?.clientType == ClientType.Personal.rawValue {
//                            UserDefaultsHelper.shared.setClientName(name: clients.first?.fullClientName ?? "")
//                        }
////                        let appDelegate = AppDelegate()
////                        appDelegate.setDocRoot()
//                        self.showDashboardVC()
//                        SVProgressHUD.dismiss()
//                    }, failure: {
//                        SVProgressHUD.dismiss()
//                    })
                } else {
//                    let appDelegate = AppDelegate()
//                    appDelegate.setDocRoot()
                        self.showDashboardVC()
                }
                SVProgressHUD.dismiss()
            }, failure: { errorMessage in
                print("errorMessage: \(errorMessage)")
                self.alert(title: "ERROR", message: errorMessage, actionButton: "CLOSE")
                SVProgressHUD.dismiss()
            })
        } else {
            alert(title: "WARNING", message: "Please fill in the fields", actionButton: "OK")
        }
    }
    
    func showDashboardVC() {
        if GetUserType.user.isUserClient() {
            if let clientTabBarController = R.storyboard.client.clientTabBarController() {
                clientTabBarController.setRoot()
            }
        } else {
            if let advisorTabBarController = R.storyboard.advisor.advisorTabBarController() {
                advisorTabBarController.setRoot()
            }
        }
    }
    
}

extension LoginVC: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if DeviceType.shared.isIphone5() || DeviceType.shared.isIphone6() {
//            UIView.animate(withDuration: 0.2) {
//                self.topConstraintLogo.constant = 90
//                self.topConstraintEmail.constant = 60
//                self.view.layoutIfNeeded()
//            }
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtFieldEmail {
            txtFieldEmail.resignFirstResponder()
            txtFieldPassword.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
}
