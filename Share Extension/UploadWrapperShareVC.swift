//
//  UploadWrapperShareVC.swift
//  Imposta
//
//  Copyright © 2020 Imposta. All rights reserved.
//

import UIKit
//import XLPagerTabStrip
//import SVProgressHUD

class UploadWrapperShareVC: UIViewController {
    @IBOutlet weak var spinner: UIActivityIndicatorView! {
        didSet {
            spinner.isHidden = true
        }
    }
    @IBOutlet weak var clientButton: UIButton!
    @IBOutlet weak var descriptionButton: UIButton!
    @IBOutlet weak var servicesButton: UIButton!
    @IBOutlet var containerViews: [UIView]!
    var serviceListVC: UploadServiceListShareVC?
    var allowsTapToDismissPopupCard = false
    var allowsSwipeToDismissPopupCard = false
    
    public var clientId: Int?

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? UploadClientListShareVC {
            vc.delegate = self
        }
        
        if let vc = segue.destination as? UploadServiceListShareVC {
            vc.delegate = self
            self.serviceListVC = vc
        }
    }
    
    

    
   
    var activeDescriptionButton = false
    
    let buttonColor = #colorLiteral(red: 0, green: 0.5764705882, blue: 1, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.stopAnimating()
        spinner.hidesWhenStopped = true
        clientButton.backgroundColor = .clear
        moveTo(index: 0)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(true)
           self.view.endEditing(true)
       }
    
    func moveTo(index: Int) {
        containerViews.forEach({$0.isHidden = true})
        containerViews[index].isHidden = false
    }

    
    
    @IBAction func btnsAction(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            clientButton.backgroundColor = .clear
            servicesButton.backgroundColor = buttonColor
            descriptionButton.backgroundColor = buttonColor
            
            moveTo(index: 0)
        case 1:
            if (clientId != nil) {
                clientButton.backgroundColor = buttonColor
                servicesButton.backgroundColor = .clear
                descriptionButton.backgroundColor = buttonColor
                
                DocumentSingleton.shared.clientId = clientId
                NotificationCenter.default.post(name: NSNotification.Name("notif1"), object: nil)
                serviceListVC?.clientId = clientId
                serviceListVC?.getClientServices()
                moveTo(index: 1)
            } else {
                self.alert(title: "WARNING", message: "Services Required", actionButton: "OK")
            }
        case 2:
            if (clientId != nil && activeDescriptionButton) {
                clientButton.backgroundColor = buttonColor
                servicesButton.backgroundColor = buttonColor
                descriptionButton.backgroundColor = .clear
                NotificationCenter.default.post(name: NSNotification.Name("notif2"), object: nil)
                moveTo(index: 2)
            } else {
                self.alert(title: "WARNING", message: "Client and Services Required", actionButton: "OK")
            }
        default:
            break
        }
    }
    
    
}

extension UploadWrapperShareVC: DocumentClientDelegate {
    func showServiceList(clientId: Int) {
        showSpinner(spinner)
        
        DocumentApi.shared.saveDocumentClient(clientId: clientId,
         success: {
            self.clientId = clientId
            
            self.clientButton.backgroundColor = self.buttonColor
            self.servicesButton.backgroundColor = .clear
            self.descriptionButton.backgroundColor = self.buttonColor
            DocumentSingleton.shared.clientId = clientId
            self.serviceListVC?.clientId = clientId
            self.serviceListVC?.getClientServices()
            self.moveTo(index: 1)
            self.hideSpinner(self.spinner)
            
         }, failure: {
            self.hideSpinner(self.spinner)
             self.alert(title: "ERROR", message: "Couldn't add service", actionButton: "OK")
         })
       
    }
    
    @IBAction func unwindToMaster(sender: UIStoryboardSegue) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension UploadWrapperShareVC: DocumentRelatedDelegate {
    func showTags() {
    }
    
    func showDesc(active: Bool) {
        self.showSpinner(self.spinner)
        DocumentApi.shared.saveDocumentClientService(docId: editDocument?.id ?? -1, serviceId: DocumentSingleton.shared.serviceId ?? -1, success: {
            
            self.activeDescriptionButton = active
            self.clientButton.backgroundColor = self.buttonColor
            self.servicesButton.backgroundColor = self.buttonColor
            self.descriptionButton.backgroundColor = .clear
            self.moveTo(index: 2)
            self.hideSpinner(self.spinner)
            
        }, failure: {
            
            self.hideSpinner(self.spinner)
            self.alert(title: "ERROR", message: "Couldn't add service", actionButton: "OK")
        })
        
        
    }
}

extension UIViewController {
    
    func showSpinner(_ spinner: UIActivityIndicatorView) {
        DispatchQueue.main.async {
            spinner.isHidden = false
            spinner.startAnimating()
        }
        
    }
    
    func hideSpinner(_ spinner: UIActivityIndicatorView) {
        DispatchQueue.main.async {
            spinner.isHidden = true
            spinner.stopAnimating()
        }
    }
    
    
    func alert(title: String, message: String, actionButton: String) {
           let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
           
           alert.setValue(alertTitleFontAndSpaceSize(message: title), forKey: "attributedTitle")
           alert.setValue(alertMessageFontAndSpaceSize(message: message), forKey: "attributedMessage")
           
           alert.addAction(UIAlertAction(title: actionButton, style: .default, handler: nil))
           self.present(alert, animated: true, completion: nil)
       }
    
    func alertWithCustomSize(title: String, message: String, actionButton: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.setValue(alertTitleFontAndSpaceSize(message: title), forKey: "attributedTitle")
        alert.setValue(alertMessageFontAndSpaceSize(message: message), forKey: "attributedMessage")
        
        alert.addAction(UIAlertAction(title: actionButton, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertWithHandler(title: String, message: String, actionButton: String, handler:@escaping ()->Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.setValue(alertTitleFontAndSpaceSize(message: title), forKey: "attributedTitle")
        alert.setValue(alertMessageFontAndSpaceSize(message: message), forKey: "attributedMessage")
        
        alert.addAction(UIAlertAction(title: actionButton, style: .default, handler: { (action) in
            handler()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertWithHandlerAction(title: String, message: String, acceptButton: String, cancelButton: String, accept:@escaping ()->Void, cancel:@escaping ()->Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: acceptButton, style: .default, handler: { (action) in
            accept()
        }))
        alert.addAction(UIAlertAction(title: cancelButton, style: .default, handler: { (action) in
            cancel()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertTitleFontAndSpaceSize(message: String) -> NSMutableAttributedString {
        let msgAttr = NSMutableAttributedString(string: message)
        msgAttr.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Roboto-Bold", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .medium),
                             range: NSMakeRange(0, msgAttr.length))
        
        return msgAttr
    }
    
    func alertMessageFontAndSpaceSize(message: String) -> NSMutableAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 2
        paragraph.alignment = NSTextAlignment.center
        
        let msgAttr = NSMutableAttributedString(string: message)
        msgAttr.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Roboto-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .regular),
                             range: NSMakeRange(0, msgAttr.length))
        
        msgAttr.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraph, range: NSMakeRange(0, msgAttr.length))
        
        return msgAttr
    }
}
