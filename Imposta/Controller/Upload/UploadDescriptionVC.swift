//
//  UploadDescriptionVC.swift
//  Imposta
//
//  Created by Rovshen Shirinzade on 9/20/20.
//  Copyright © 2020 Imposta. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SVProgressHUD

class UploadDescriptionVC: UIViewController, IndicatorInfoProvider {
    
    @IBOutlet weak var viewDesc: UIView!
    @IBOutlet weak var txtView: UITextView!
    @IBOutlet weak var buttonSaveDesc: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        txtView.text = editDocument?.desc
        txtView.becomeFirstResponder()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeKeyboard)))
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Description")
    }
    
    @objc func closeKeyboard() {
        txtView.resignFirstResponder()
    }
        
    @IBAction func btnSave(_ sender: Any) {
        if txtView.text.count > 5000 {
            alert(title: "WARNING", message: "Description text must be less than 5000 characters", actionButton: "OK")
        } else {
            SVProgressHUD.show()
            DocumentApi.shared.saveDocumentDescription(documentId: editDocument?.id ?? 0, desc: txtView.text!, success: {
                self.alertWithHandler(title: "SUCCESS", message: "Document has successfully saved", actionButton: "OK") {
                    NotificationCenter.default.post(name: .documentSaved, object: nil)
                    self.dismiss(animated: true, completion: nil)
                }
                SVProgressHUD.dismiss()
            }, failure: {
                SVProgressHUD.dismiss()
            })
        }
    }
    
}

extension UploadDescriptionVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            txtView.resignFirstResponder()
        }
        
        return true
    }
}
