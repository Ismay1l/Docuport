//
//  InboxDetailVC.swift
//  Imposta
//
//  Created by Shamkhal Guliyev on 9/12/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit
import QuickLook
import SVProgressHUD

protocol InboxDetailDelegate {
    func documentEdited()
}

class InboxDetailVC: UIViewController {
    
    @IBOutlet var lblFileName: UILabel!
    @IBOutlet var lblAccount: UILabel!
    @IBOutlet var lblStatusNote: UILabel!
    @IBOutlet var lblDescription: UILabel!
    @IBOutlet weak var buttonDownload: UIButton!
    @IBOutlet weak var buttonShare: UIButton!
    
    var fileName = ""
    var urlPreviewItem: URL?
    var document: ResultDocument?
    var delegate: InboxDetailDelegate?
    var isClient = false, isFromDownload = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fileName = (document!.attachment!.genFileName)!
        
        if isFromDownload {
            buttonDownload.isHidden = true
        }
        
        if isClient {
            buttonShare.setImage(UIImage(named: "edit"), for: .normal)
        }
        
        lblStatusNote.text = document?.status
        lblDescription.text = document?.desc
        lblAccount.text = document?.creatorUser?.userName
        lblFileName.text = document?.attachment?.fileName
    }
    
    @objc func serviceChoice() {
        let serviceVC = getVC(id: "ServiceListVC") as! ServiceListVC
        serviceVC.document = document
        serviceVC.isFromFileUpload = true
        serviceVC.delegate = self
        show(serviceVC, sender: nil)
    }
    
    func preview() {
        urlPreviewItem = temporaryFileDestination(fileName: fileName)
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
                    appDelegate.saveFile(type: .outbox, document: self.document!, path: path.path)
                } else {
                    appDelegate.saveFile(type: .inbox, document: self.document!, path: path.path)
                }
                self.alert(title: "SUCCESS", message: "Download completed", actionButton: "OK")
            }, failure: {
                SVProgressHUD.dismiss()
                self.alert(title: "ERROR", message: "File can't be displayed", actionButton: "OK")
            })
        }
    }
    
    @IBAction func btnShare(_ sender: Any) {
        if isClient {
            serviceChoice()
        } else {
            preview()
        }
    }
    
    @IBAction func btnClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension InboxDetailVC: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return urlPreviewItem! as QLPreviewItem
    }
}

extension InboxDetailVC: ServiceListDelegate {
    func clientServiceAndEmployee(client: ResultClients) {}
    
    func serviceSelection(clientService: ClientServiceData) {
        SVProgressHUD.show()        
        DocumentApi.shared.saveDocumentClientService(docId: document?.id ?? 0, serviceId: clientService.id!, success: {
            self.delegate?.documentEdited()
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
