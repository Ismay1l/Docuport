//
//  UploadDescriptionVC.swift
//  Imposta
//
//  Created by Rovshen Shirinzade on 9/20/20.
//  Copyright © 2020 Imposta. All rights reserved.
//

import UIKit
//import XLPagerTabStrip
//import SVProgressHUD

class UploadDescriptionShareVC: UIViewController {
    
    @IBOutlet weak var viewDesc: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView! {
        didSet {
            spinner.isHidden = true
        }
    }
    @IBOutlet weak var txtView: UITextView!
    @IBOutlet weak var buttonSaveDesc: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.stopAnimating()
        spinner.hidesWhenStopped = true
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(true)
           self.view.endEditing(true)
       }
    
    func setup() {
        txtView.text = editDocument?.desc
        txtView.becomeFirstResponder()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeKeyboard)))
    }
    
    
    @objc func closeKeyboard() {
        txtView.resignFirstResponder()
    }
        
    @IBAction func btnSave(_ sender: Any) {
        if txtView.text.count > 5000 {
            alert(title: "WARNING", message: "Description text must be less than 5000 characters", actionButton: "OK")
        } else {
           showSpinner(spinner)
            DocumentApi.shared.saveDocumentDescription(documentId: editDocument?.id ?? 0, desc: txtView.text!, success: {
                self.alertWithHandler(title: "SUCCESS", message: "Document has successfully saved", actionButton: "OK") {
                     NotificationCenter.default.post(name: Notification.Name("to_master"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                }
                self.hideSpinner(self.spinner)

            }, failure: {
                self.hideSpinner(self.spinner)
            })
        }
    }
    
}

extension UploadDescriptionShareVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            txtView.resignFirstResponder()
        }
        
        return true
    }
}

