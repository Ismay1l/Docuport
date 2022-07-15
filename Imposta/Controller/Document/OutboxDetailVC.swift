//
//  OutboxDetailVC.swift
//  Imposta
//
//  Created by Shamkhal Guliyev on 9/12/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit
import QuickLook
import Alamofire
import SVProgressHUD

class OutboxDetailVC: UIViewController {    
    @IBOutlet var lblDocumentName: UILabel!
    @IBOutlet var lblAccount: UILabel!
    @IBOutlet var lblService: UILabel!
    @IBOutlet var lblRelatedDoc: UILabel!
    @IBOutlet var lblDescription: UILabel!
    @IBOutlet weak var buttonView: UIButton!
    @IBOutlet weak var buttonDownload: UIButton!
    @IBOutlet weak var buttonEdit: UIButton!
    @IBOutlet weak var viewClient: UIView!
    @IBOutlet weak var viewClientHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewClientBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewClientTopConstraint: NSLayoutConstraint!
    
    var strDocs = ""
    var fileName = ""
    var urlPreviewItem: URL!
    var document: ResultDocument?
    var isClient = false, isFromDownload = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(documentSaved), name: NSNotification.Name("documentSaved"), object: nil)
    }
    
    @objc func documentSaved() {
        dismiss(animated: true, completion: nil)
    }
    
    func setup() {
        fileName = (document!.attachment!.genFileName)!
        
        if document?.relatedDocs?.count ?? 0 > 0 {
            for doc in document!.relatedDocs! {
                strDocs.append(doc.docNumber!)
                strDocs.append(",")
            }
            lblRelatedDoc.text = strDocs
        }
        
        if isFromDownload {
            buttonDownload.isHidden = true
        }
        
        if isClient {
            viewClient.isHidden = true
            viewClientTopConstraint.constant = 0
            viewClientBottomConstraint.constant = 0
            viewClientHeightConstraint.constant = 0
            buttonEdit.setImage(UIImage(named: "share"), for: .normal)
        }
        
        urlPreviewItem = URL(string: "")
        lblService.text = document?.service?.name
        lblDescription.text = document?.desc
        lblAccount.text = document?.client?.name
        lblDocumentName.text = document?.attachment?.fileName
    }
    
    @objc func serviceChoice() {
        let serviceVC = getVC(id: "ServiceListVC") as! ServiceListVC
        serviceVC.document = document
        serviceVC.isFromFileUpload = true
        serviceVC.delegate = self
        show(serviceVC, sender: nil)
    }
    
    func preview() {
        urlPreviewItem = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName)")
        SVProgressHUD.show()
        AppApi.shared.downloadImage(fileName, success: { data in
            SVProgressHUD.dismiss()
            try! data.write(to: self.urlPreviewItem!, options: .atomic)
            let previewVC = QLPreviewController()
            previewVC.dataSource = self
            self.present(previewVC, animated: true, completion: nil)
        }, failure: {
            SVProgressHUD.dismiss()
            self.alert(title: "ERROR", message: "File can't be displayed", actionButton: "OK")
        })
    }
    
    @IBAction func btnShow(_ sender: Any) {
        preview()
    }
    
    @IBAction func btnDownload(_ sender: Any) {
        let path = self.downloadedFileDestination(fileName: self.fileName)
        if FileManager.default.fileExists(atPath: path.path) {
            self.alert(title: "WRNING", message: "The file already exists at path", actionButton: "OK")
        } else {
            SVProgressHUD.show()
            AppApi.shared.downloadImage(fileName, success: { data in
                SVProgressHUD.dismiss()
                try! data.write(to: path, options: .atomic)
                let appDelegate = AppDelegate()
                if UserDefaultsHelper.shared.getUserType() == UserType.client.rawValue {
                    appDelegate.saveFile(type: .inbox, document: self.document!, path: path.path)
                } else {
                    appDelegate.saveFile(type: .outbox, document: self.document!, path: path.path)
                }
                self.alert(title: "SUCCESS", message: "Download completed", actionButton: "OK")
            }, failure: {
                SVProgressHUD.dismiss()
                self.alert(title: "ERROR", message: "File can't be displayed", actionButton: "OK")
            })
        }
    }
    
    @IBAction func btnEdit(_ sender: Any) {
        if isClient {
            preview()
        } else {
            editDocument = document
            if UserDefaultsHelper.shared.getUserType() == UserType.client.rawValue {
                serviceChoice()
            } else {
                presentNavFullScreen(id: "documentEditNav")
            }
        }
    }
    
    @IBAction func btnClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension OutboxDetailVC: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return urlPreviewItem! as QLPreviewItem
    }
}

extension OutboxDetailVC: ServiceListDelegate {
    func clientServiceAndEmployee(client: ResultClients) {}
    
    func serviceSelection(clientService: ClientServiceData) {
        self.dismiss(animated: true, completion: nil)
        
        SVProgressHUD.show()
        DocumentApi.shared.saveDocumentClientService(docId: document?.id ?? 0, serviceId: clientService.id!, success: {
            self.alertWithHandler(title: "SUCCESS", message: "Service has added successfully", actionButton: "OK") {
                self.dismiss(animated: true, completion: nil)
            }
            SVProgressHUD.dismiss()
        }, failure: {
            SVProgressHUD.dismiss()
            self.alert(title: "ERROR", message: "Couldn't add service", actionButton: "OK")
        })
    }
}
