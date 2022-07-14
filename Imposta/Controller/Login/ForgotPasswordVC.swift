//
//  ForgotPasswordVC.swift
//  Imposta
//
//  Created by Shamkhal Guliyev on 11/3/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit
import SVProgressHUD

class ForgotPasswordVC: UIViewController {
    
    
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var txtFieldEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeKeyboard)))
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(noti:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(noti:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        viewHeight.constant = UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.size.height - (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
        
    }
    
    @objc func closeKeyboard() {
        txtFieldEmail.resignFirstResponder()
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
    
    @IBAction func btnSubmit(_ sender: Any) {
        
        if txtFieldEmail.text?.count == 0 {
            alert(title: "WARNING", message: "Please enter email address", actionButton: "OK")
        } else {
            if isValidEmail(txtFieldEmail.text!) {
                SVProgressHUD.show()
                AppApi.shared.forgotPassword(email: txtFieldEmail.text!, success: {
                    self.alert(title: "SUCCESS", message: "Password change link has sent to your email", actionButton: "OK")
                    SVProgressHUD.dismiss()
                }, failure: { message in
                    SVProgressHUD.dismiss()
                    self.alert(title: "ERROR", message: message, actionButton: "OK")
                })
            } else {
                alert(title: "WARNING", message: "Email address is not valid", actionButton: "OK")
            }
        }
    }
    
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension ForgotPasswordVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
