//
//  DocumentUploadVC.swift
//  Imposta
//
//  Created by Shamkhal on 12/14/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit
import QuartzCore
import SVProgressHUD
import MobileCoreServices

class DocumentUploadVC: UIViewController {
    
    @IBOutlet weak var viewCenter: UIView!
    @IBOutlet weak var viewFile: UIView!
    @IBOutlet weak var progressUpload: UIProgressView!
    @IBOutlet weak var heightConstraintViewFile: NSLayoutConstraint!
    @IBOutlet weak var heighConstraintViewCenter: NSLayoutConstraint!
        
    var fileData: Data?
    var documentId: Int?
    var imgFileName: String?
    var fileName: String = ""
    var isFileImage = false
    
    var didCancel: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressUpload.layer.cornerRadius = 15
        progressUpload.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if DocumentSingleton.shared.isFileIploaded {
            dismiss(animated: true, completion: nil)
           DocumentSingleton.shared.isFileIploaded = false
        } else {
            setup()
        }
    }
    
    func setup() {
        if isFileImage {
            fileName = imgFileName ?? ""
            uploadFile()
            print("uploadfile setup")
        } else {
            fileSelection()
            viewFile.isHidden = true
            heightConstraintViewFile.constant = 0
            heighConstraintViewCenter.constant = 200
        }
        
//        let title = "Upload your files "
//        let desc = "try to upload more files to see them here"
//        let attr = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25, weight: .medium)])
//        attr.append(NSAttributedString(string: desc, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .regular)]))
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        addDash()
//    }
    
//    func addDash() {
//        let dashLayer = CAShapeLayer()
//        dashLayer.fillColor = nil
//        dashLayer.frame = viewDesc.bounds
//        dashLayer.lineDashPattern = [10, 10]
//        dashLayer.path = UIBezierPath(rect: viewDesc.bounds).cgPath
//        dashLayer.strokeColor = UIColor(hexStr: "C8C8C8", colorAlpha: 1).cgColor
//        viewDesc.layer.addSublayer(dashLayer)
//    }
    
    @objc func fileSelection() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        documentPicker.modalPresentationStyle = .pageSheet
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    @objc func serviceChoice() {
        let VC = initController(with: "Client", withIdentifier: "ClientUploadWrapperVC") as! ClientUploadWrapperVC
        VC.clientDelegate = self
        VC.documentId = documentId
        VC.modalPresentationStyle = .fullScreen
        self.present(VC, animated: true)
    }
    
    func uploadFile() {
         viewFile.isHidden = false
         heightConstraintViewFile.constant = 39
         heighConstraintViewCenter.constant = 40
        
        DocumentApi.shared.uploadDocument(uploadFile: fileData!, fileName: fileName, isImage: isFileImage, uploadProgress: { progressValue in
            self.progressUpload.progress = Float(progressValue)
        }, success: { response in
            
            editDocument = response.result
            self.documentId = response.result?.id
            DocumentSingleton.shared.docID = response.result?.id
            print("DocumentSingleton.shared.docID \(DocumentSingleton.shared.docID)")
            if UserDefaultsHelper.shared.getUserType() == UserType.Advisor.rawValue || UserDefaultsHelper.shared.getUserType() == UserType.Employee.rawValue {
                if let VC = R.storyboard.advisor.uploadWrapperVC() {
                    VC.modalPresentationStyle = .fullScreen
                    self.present(VC, animated: true)
                }
                //self.alertWithHandler(title: "File has uploaded successfully", message: "", actionButton: "OK") {}
            } else {
                self.serviceChoice()
            }
        }) {
            self.alert(title: "ERROR", message: "Couldn't upload the file", actionButton: "OK")
        }
    }
    
    @IBAction func btnClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        didCancel?()
    }
}

extension DocumentUploadVC: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if urls.count > 0 {
            fileData = try! Data(contentsOf: urls[0])
            fileName = (urls[0].absoluteString as NSString).lastPathComponent
            uploadFile()
            print("uploadfile documentPicker")
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension DocumentUploadVC: ClientUploadDelegate {
    func serviceSelection(clientService: ClientServiceData) {
        // do nothing
    }
    
    func documentUploaded() {
        // do nothing
    }
}
