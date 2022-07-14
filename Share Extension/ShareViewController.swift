//
//  ShareViewController.swift
//  Share Extension
//
//  Created by Ulxan Emiraslanov on 10/2/20.
//  Copyright © 2020 Imposta. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {

    var dataName = ""
    var isImage = false
    var selectedData: Data?
    override func isContentValid() -> Bool {
     
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
       
        NotificationCenter.default.addObserver(self, selector: #selector(toMaster), name: Notification.Name("to_master"), object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         textView.isHidden = true
         textView.isEditable = false
        
    }

    @objc func toMaster(_ notification: Notification) {
        dismiss(animated: true, completion: nil)
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    override func didSelectPost() {
         self.view.endEditing(true)
         if UserDefaultsHelper.shared.getToken() != "" {
            handleSharedFile()
         } else {
            alertWithHandler(title: "Warning!", message: "You have to login to upload", actionButton: "OK") {
                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
            }
        }
            
        
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let uploadVC = segue.destination as? DocumentUploadShareVC {
        uploadVC.isFileImage = isImage
        uploadVC.imgFileName = dataName
        uploadVC.fileData = selectedData
        
        }
    }
    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

   private func handleSharedFile() {
     // extracting the path to the URL that is being shared
     let attachments = (self.extensionContext?.inputItems.first as? NSExtensionItem)?.attachments ?? []
     let contentType = kUTTypeData as String
     for provider in attachments {
       // Check if the content type is the same as we expected
       if provider.hasItemConformingToTypeIdentifier(contentType) {
         provider.loadItem(forTypeIdentifier: contentType,
                           options: nil) { [unowned self] (data, error) in
         // Handle the error here if you want
         guard error == nil else { return }
              
         if let url = data as? URL,
            let attachedData = try? Data(contentsOf: url) {
            self.selectedData = attachedData
            self.dataName = (url.absoluteString as NSString).lastPathComponent
            
            if url.pathExtension == "jpg" ||
                url.pathExtension == "jpeg" ||
                url.pathExtension == "png" ||
                url.pathExtension == "gif" {
                self.isImage = true
            }
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "to_file_upload", sender: nil)
            }
         } else {
           // Handle this situation as you prefer
           fatalError("Impossible to save image")
         }
       }}
     }
   }
}
