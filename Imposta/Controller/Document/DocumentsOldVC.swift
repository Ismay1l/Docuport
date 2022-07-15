//
//  DocumentsOldVC.swift
//  Imposta
//
//  Created by Shamkhal Guliyev on 8/29/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit
import SVProgressHUD

class DocumentsOldVC: UIViewController {
    
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var tableDocuments: UITableView!
    @IBOutlet weak var buttonPlus: UIButton!
    @IBOutlet weak var viewFileUpload: UIView!
    @IBOutlet weak var buttonClose: UIButton!
    @IBOutlet weak var lblTakePhoto: UILabel!
    @IBOutlet weak var lblUploadFile: UILabel!
    @IBOutlet weak var leadingConstraintFileUploadView: NSLayoutConstraint!
    
    var limit = 50
    var isFinish = false, isSearch = false
    var imagePicker: UIImagePickerController!
    
    var searchDocument: DocumentSearch?
    var arrDocument = [ResultDocument]()
    var arrDocumentCopy = [ResultDocument]()
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setup()
        
        NotificationCenter.default.addObserver(self, selector: #selector(documentReset), name: NSNotification.Name(rawValue: "documentReset"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(documentSearch), name: NSNotification.Name(rawValue: "documentSearch"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(documentSaved), name: NSNotification.Name(rawValue: "documentSaved"), object: nil)
    }
    
    fileprivate func setup() {
        searchDocument = DocumentSearch()
        searchType = .documents
        getDocument(docType: documentType.rawValue)
        
        if documentType == DocumentType.inbox {
            segment.selectedSegmentIndex = 0
        } else {
            segment.selectedSegmentIndex = 1
        }
        
        addMenuNavButton()
        
        let menuButton = UIBarButtonItem(image: UIImage(named: "search"), style: .plain, target: self, action: #selector(openDocSearch))
        menuButton.tintColor = UIColor(hexStr: "44BA8B", colorAlpha: 1)
        self.navigationItem.rightBarButtonItem = menuButton
        
        let font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        segment.setTitleTextAttributes([NSAttributedString.Key.font: font as Any], for: .normal)
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableDocuments.addSubview(refreshControl)
        
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        viewFileUpload.layer.borderWidth = 2
        viewFileUpload.layer.borderColor = UIColor(hexStr: "3AB886", colorAlpha: 1).cgColor
        leadingConstraintFileUploadView.constant = view.frame.width-20
        lblTakePhoto.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(takePhoto)))
        lblUploadFile.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openFileUpload)))
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            lblTakePhoto.isHidden = true
        }
    }
    
    @objc func openDocSearch() {
        let vc = getVC(id: "DocumentSearchVC") as! DocumentSearchVC
        if UserDefaultsHelper.shared.getUserType() == UserType.client.rawValue {
            vc.isClient = true
        }
        customPresentViewController(presenter, viewController: vc, animated: true)
    }
    
    @objc func documentSaved() {
        arrDocument.removeAll()
        tableDocuments.reloadData()
        segment.selectedSegmentIndex = 1
        documentType = .outbox
        getDocument(docType: documentType.rawValue)
        closeFileUploadView()
    }
    
    @objc func documentReset() {
        isSearch = false
        searchDocument = DocumentSearch()        
        arrDocument.removeAll()
        arrDocument = arrDocumentCopy
        tableDocuments.reloadData()
    }
    
    @objc func documentSearch(notification: Notification) {
        print("documentSearch..")
        arrDocument.removeAll()
        tableDocuments.reloadData()
        let userInfo = notification.userInfo as! [String: DocumentSearch]
        searchDocument = userInfo["searchDoc"]
        isSearch = true
        getDocument(docType: documentType.rawValue)
    }
    
    @objc func refresh() {
        arrDocument.removeAll()
        tableDocuments.reloadData()
        getDocument(docType: documentType.rawValue)
    }
    
    @objc func takePhoto() {
        let actionSheet = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        let camera = UIAlertAction(title: "Camera", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.camera()
        })
        
        let photoLibrary = UIAlertAction(title: "Choose from Library", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.photoLibrary()
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(camera)
        actionSheet.addAction(photoLibrary)
        actionSheet.addAction(cancel)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func openFileUpload() {
        customPresentViewController(presenter, viewController: getVC(id: "DocumentUploadVC"), animated: true)
    }
    
    func getDocument(docType: String) {
        SVProgressHUD.show()
        DocumentApi.shared.getDocument(docType: docType, limit: limit, offset: arrDocument.count, serviceId: 0, searchText: "", isSearch: isSearch, success: { response in
            self.refreshControl.endRefreshing()
            if response.documents!.count < self.limit {
                self.isFinish = true
            }
            if response.documents!.count == 0 {
                if self.isSearch { //search'den gelende willDisplay methodu call edilir ona gore user search'den gelirse burda array'i remove edirik
                    self.arrDocument.removeAll()
                }
            } else {
                for doc in response.documents! {
                    self.arrDocument.append(doc)
                }
            }
            if !self.isSearch {
                self.arrDocumentCopy = self.arrDocument
            }
            SVProgressHUD.dismiss()
            self.tableDocuments.reloadData()
        }, failure: { code, errorMessage in
            SVProgressHUD.dismiss()
            self.tableDocuments.reloadData()
            self.refreshControl.endRefreshing()
            if code == 0 {
                self.alertWithHandler(title: errorMessage, message: "", actionButton: "OK") {
                    SVProgressHUD.show()
                    AppApi.shared.loginWithUserDefaults(success: {                        
                        self.refresh()
                        SVProgressHUD.dismiss()
                    }, failure: {
                        SVProgressHUD.dismiss()
                    })
                }
            }            
        })
    }
    
    func camera() {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    func photoLibrary() {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func closeFileUploadView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.leadingConstraintFileUploadView.constant = self.view.frame.width-20
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.viewFileUpload.isHidden = true
        })
    }
    
    @IBAction func segmentTap(_ sender: Any) {
        if segment.selectedSegmentIndex == 0 { //inbox
            documentType = .inbox
        } else { //outbox
            documentType = .outbox
        }
        
        arrDocument.removeAll()
        getDocument(docType: documentType.rawValue)
    }
    
    @IBAction func btnPlus(_ sender: Any) {
        viewFileUpload.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.leadingConstraintFileUploadView.constant = 20
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func btnClose(_ sender: Any) {
        closeFileUploadView()
    }
}

extension DocumentsOldVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrDocument.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentCell") as! DocumentCell
        
        cell.delegate = self
        cell.reloadData(document: arrDocument[indexPath.row], documentType: documentType)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if UserDefaultsHelper.shared.getUserType() == UserType.client.rawValue {
            if segment.selectedSegmentIndex == 0 {
                let vc = getVC(id: "OutboxDetailVC") as! OutboxDetailVC
                vc.isClient = true
                vc.document = arrDocument[indexPath.row]
                
                let nav = getNav(id: "outboxDetailNav")
                nav.viewControllers = [vc]
                customPresentViewController(presenter, viewController: nav, animated: true)
            } else {
                let vc = getVC(id: "InboxDetailVC") as! InboxDetailVC
                vc.delegate = self
                vc.isClient = true
                vc.document = arrDocument[indexPath.row]
                customPresentViewController(presenter, viewController: vc, animated: true)
            }
        } else {
            if segment.selectedSegmentIndex == 0 {
                let vc = getVC(id: "InboxDetailVC") as! InboxDetailVC
                vc.delegate = self
                vc.document = arrDocument[indexPath.row]
                customPresentViewController(presenter, viewController: vc, animated: true)
            } else {
                let vc = getVC(id: "OutboxDetailVC") as! OutboxDetailVC
                vc.document = arrDocument[indexPath.row]
                
                let nav = getNav(id: "outboxDetailNav")
                nav.viewControllers = [vc]
                customPresentViewController(presenter, viewController: nav, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !isFinish {
            if indexPath.row == arrDocument.count - 1 {
                getDocument(docType: documentType.rawValue)
            }
        }
    }
}

extension DocumentsOldVC: DocumentCellDelegate {
    func setDocumentStatus(documentId: Int, status: DocumentStatusValue) {
        var statusCode = 0
        
        switch status {
        case .open:
            statusCode = 2
        case .inProgress:
            statusCode = 3
        case .done:
            statusCode = 4
        default:
            break
        }
        
        SVProgressHUD.show()
        DocumentApi.shared.setDocumentStatus(documentId: documentId, documentStatus: statusCode, success: {
            self.alert(title: "SUCCESS", message: "Status has successfully changed", actionButton: "OK")
            let idx = self.arrDocument.index(where: {
                $0.id == documentId
            })
            self.arrDocument[idx!].status = status.rawValue
            self.tableDocuments.reloadData()
            SVProgressHUD.dismiss()
        }, failure: {
            SVProgressHUD.dismiss()
            self.alert(title: "ERROR", message: "Could't change document status", actionButton: "OK")
        })
    }
}

extension DocumentsOldVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var imageName = ""
        let docImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage        
        if imagePicker.sourceType == .camera {
            imageName = "image_" + UUID().uuidString + ".jpeg"
        } else {
            let imagePath = (info[UIImagePickerController.InfoKey.imageURL] as! URL).absoluteString
            imageName = (imagePath as NSString).lastPathComponent
        }
        imagePicker.dismiss(animated: true, completion: nil)
        
        let uploadVC = getVC(id: "DocumentUploadVC") as! DocumentUploadVC
        uploadVC.isFileImage = true
        uploadVC.imgFileName = imageName
        uploadVC.fileData = docImage.resize().pngData()
//        uploadVC.fileData = docImage.jpegData(compressionQuality: 0.6)
        customPresentViewController(presenter, viewController: uploadVC, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

extension DocumentsOldVC: InboxDetailDelegate {
    func documentEdited() {
        arrDocument.removeAll()
        arrDocumentCopy.removeAll()
        tableDocuments.reloadData()
        getDocument(docType: documentType.rawValue)
    }
}
