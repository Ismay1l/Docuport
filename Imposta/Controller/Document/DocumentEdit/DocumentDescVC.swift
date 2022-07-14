//
//  DocumentDescVC.swift
//  Imposta
//
//  Created by Shamkhal on 11/17/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit
import SVProgressHUD
import XLPagerTabStrip

class DocumentDescVC: UIViewController, IndicatorInfoProvider {
    @IBOutlet weak var viewDesc: UIView!
    @IBOutlet weak var txtView: UITextView!
    @IBOutlet weak var buttonSaveDesc: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "descriptionPage"), object: nil)
    }
    
    func setup() {
        txtView.text = editDocument?.desc        
        txtView.becomeFirstResponder()
        viewDesc.layer.cornerRadius = 10
        viewDesc.layer.shadowOpacity = 0.35
        viewDesc.layer.masksToBounds = false
        viewDesc.layer.shadowOffset = CGSize(width: 5, height: 7)
        viewDesc.layer.shadowColor = UIColor(hexStr: strColorCode, colorAlpha: 0.5).cgColor
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeKeyboard)))
    }
    
    @objc func closeKeyboard() {
        txtView.resignFirstResponder()
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Description")
    }
        
    @IBAction func btnSaveDesc(_ sender: Any) {
        if txtView.text.count > 5000 {
            alert(title: "WARNING", message: "Description text must be less than 5000 characters", actionButton: "OK")
        } else {
            SVProgressHUD.show()
            DocumentApi.shared.saveDocumentDescription(documentId: editDocument?.id ?? 0, desc: txtView.text!, success: {
                NotificationCenter.default.post(name: NSNotification.Name("documentSaved"), object: nil)
                self.alertWithHandler(title: "SUCCESS", message: "Document has successfully saved", actionButton: "OK") {
                    self.dismiss(animated: true, completion: nil)
                }
                SVProgressHUD.dismiss()
            }, failure: {
                SVProgressHUD.dismiss()
            })
        }
    }
}

extension DocumentDescVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            txtView.resignFirstResponder()
        }
        
        return true
    }
}
