//
//  DocumentUploadVC.swift
//  Imposta
//
//  Created by Shamkhal on 12/14/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit
import QuartzCore
//import SVProgressHUD
import MobileCoreServices

class DocumentUploadShareVC: UIViewController {
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var viewCenter: UIView!
    @IBOutlet weak var viewFile: UIView!
    @IBOutlet weak var viewDesc: UIView!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblFileName: UILabel!
    @IBOutlet weak var lblService: UILabel!
    @IBOutlet weak var progressUpload: UIProgressView!
    @IBOutlet weak var heightConstraintViewFile: NSLayoutConstraint!
    @IBOutlet weak var heighConstraintViewCenter: NSLayoutConstraint!
        
    var fileData: Data?
    var documentId: Int?
    var imgFileName: String?
    var isFileImage = false
    
    var uploadFlag = false
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ShareUploadServicesClientVC {
            vc.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.stopAnimating()
        spinner.hidesWhenStopped = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if DocumentSingleton.shared.isFileIploaded {
            dismiss(animated: true, completion: nil)
           DocumentSingleton.shared.isFileIploaded = false
        } else {
            setup()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.view.endEditing(true)
        addDash()
    }
    
    func setup() {
            lblFileName.text = imgFileName
            uploadFile()
        
        let title = "Upload your files "
        let desc = "try to upload more files to see them here"
        let attr = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25, weight: .medium)])
        attr.append(NSAttributedString(string: desc, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .regular)]))
        
        lblDesc.attributedText = attr
        
        lblService.isHidden = true
        lblService.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(serviceChoice)))
    }
    

    
    func addDash() {
        let dashLayer = CAShapeLayer()
        dashLayer.fillColor = nil
        dashLayer.frame = viewDesc.bounds
        dashLayer.lineDashPattern = [10, 10]
        dashLayer.path = UIBezierPath(rect: viewDesc.bounds).cgPath
        dashLayer.strokeColor = UIColor(hexStr: "C8C8C8", colorAlpha: 1).cgColor
        viewDesc.layer.addSublayer(dashLayer)
    }
    
    
    
    @objc func serviceChoice() {
        
        self.performSegue(withIdentifier: "to_client_services", sender: nil)
        
    }
    
    func changeService(title: String) {
        lblService.text = title
        lblService.textColor = UIColor(hexStr: "007AFF", colorAlpha: 1)
    }
    
    func uploadFile() {
        self.view.endEditing(true)
        
        if uploadFlag { return }
        self.uploadFlag = true

        viewFile.isHidden = false
        heightConstraintViewFile.constant = 25
        heighConstraintViewCenter.constant = 240
        DocumentApi.shared.uploadDocument(uploadFile: fileData!, fileName: lblFileName.text!, isImage: isFileImage, uploadProgress: { progressValue in
          
            self.progressUpload.progress = Float(progressValue)
        }, success: { response in
            editDocument = response.result
            self.documentId = response.result?.id
            DocumentSingleton.shared.docID = response.result?.id
            
            if UserDefaultsHelper.shared.getUserType() == UserType.advisor.rawValue || UserDefaultsHelper.shared.getUserType() == UserType.employee.rawValue {
                self.lblService.isHidden = true
//                self.alertWithHandler(title: "File has uploaded successfully", message: "", actionButton: "OK") {}
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "to_uploadWrapper", sender: nil)
                }
                 
            } else {
                self.serviceChoice()
                self.lblService.isHidden = false
            }
        }) {
            self.alert(title: "ERROR", message: "Couldn't upload the file", actionButton: "OK")
        }
    }
    
    @IBAction func btnClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}


extension DocumentUploadShareVC: ServiceListDelegate {
    func clientServiceAndEmployee(client: ResultClients) {}
    
    func serviceSelection(clientService: ClientServiceData) {
        showSpinner(spinner)
       
        DocumentApi.shared.saveDocumentClientService(docId: documentId!, serviceId: clientService.id!, success: {
            self.changeService(title: clientService.name ?? "")
           // self.dismiss(animated: true, completion: nil)
            self.alertWithHandler(title: "SUCCESS", message: "Service has added successfully", actionButton: "OK") {
//
                NotificationCenter.default.post(name: Notification.Name("to_master"), object: nil)
            }
            self.hideSpinner(self.spinner)
        }, failure: {
            self.hideSpinner(self.spinner)
            self.alert(title: "ERROR", message: "Couldn't add service", actionButton: "OK")
        })
    }
}
