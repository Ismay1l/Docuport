//
//  UploadClientVC.swift
//  Imposta
//
//  Created by Rovshen Shirinzade on 9/15/20.
//  Copyright © 2020 Imposta. All rights reserved.
//

import UIKit
import QuickLook
import SVProgressHUD
import MarqueeLabel

class UploadClientVC: UIViewController {
    @IBOutlet weak var logoIcon: UIImageView!
    @IBOutlet weak var accountNameLbl: MarqueeLabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var logoutIcon: UIImageView!
    @IBOutlet weak var pageTitleLbl: UILabel!
    
    var arrDocument = [ResultDocument]()
    var imagePicker = UIImagePickerController()
    var refreshControl = UIRefreshControl()
    
    var limit = 50
    var isFinish = false, isSearch = false
    var urlPreviewItem: URL?
    
    var showSearchView = false
    
    var fileData: Data?
    var documentId: Int?
    var imgFileName: String?
    var isFileImage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(documentUpload), name: .documentSaved, object: nil)
        
        searchView.isHidden = true
        searchTF.addTarget(self, action: #selector(searchText(_:)), for: .editingChanged)
        
        accountNameLbl.type = .continuous
        accountNameLbl.animationCurve = .easeInOut
        accountNameLbl.fadeLength = 10.0
        
        documentType = .outbox
        setupInteractions()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        accountNameLbl.text = UserDefaultsHelper.shared.getClientName()
        
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
    
    func camera() {
        self.getImage(fromSourceType: .camera)
    }
    
    func photoLibrary() {
        self.getImage(fromSourceType: .photoLibrary)
    }
    
    private func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    @objc func documentUpload() {
        tabBarController?.selectedIndex = 0
        self.dismiss(animated: true, completion: nil)
    }
    
    private func canceled() {
        tabBarController?.selectedIndex = 0
    }
    
    @IBAction func searchBtnAction(_ sender: UIButton) {
        if showSearchView {
            searchView.isHidden = true
            pageTitleLbl.isHidden = false
            showSearchView = false
            view.endEditing(true)
        } else {
            searchView.isHidden = false
            pageTitleLbl.isHidden = true
            showSearchView = true
            searchTF.becomeFirstResponder()
            searchTF.text = ""
        }
    }
    
    @objc private func searchText(_ textfield: UITextField) {
        refresh()
    }
}

extension UploadClientVC {
    @IBAction func showAccountsAction(_ sender: UIButton) {
        if let VC = R.storyboard.client.accountsVC() {
            SVProgressHUD.show()
            AppApi.shared.getAllAccountNew { response in
                if let clients = response as? [AccountOnHeaderElement] {
                    VC.arrUserNew = clients
                    VC.delegate = self
                    let showPopup = SBCardPopupViewController(contentViewController: VC)
                    showPopup.show(onViewController: self)
                    SVProgressHUD.dismiss()
                }
            } failure: {
                SVProgressHUD.dismiss()
            }
//            AppApi.shared.getAllAccount(success: { response in
//                guard let clients = response.result else { return }
//                VC.arrUser = clients
//                VC.delegate = self
//                let showPopup = SBCardPopupViewController(contentViewController: VC)
//                showPopup.show(onViewController: self)
//                SVProgressHUD.dismiss()
//            }, failure: {
//                SVProgressHUD.dismiss()
//            })
        }
    }
    
    @IBAction func shareBtnAction(_ sender: UIButton) {
        let row = arrDocument.index(where: { $0.id == sender.tag }) ?? 0
        let file = arrDocument[row]
        shareFile(file)
    }
    
    func setupInteractions() {
        logoIcon.isUserInteractionEnabled = true
        logoIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onHome)))
//        setLogout(view: logoutIcon)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onLogout))
        self.logoutIcon.isUserInteractionEnabled = true
        self.logoutIcon.addGestureRecognizer(gesture)
    }
    
    @objc func onLogout() {
                print(#function)
                ProfileApi.shared.logoutProfile { result in
                    print(result)
                }
            let appDelegate = AppDelegate()
            appDelegate.setRoot()
    //        setLogout(view: logoutIcon)
            print("gestured used")
    }
}

extension UploadClientVC {
    fileprivate func setup() {
        getDocument(docType: documentType.rawValue)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func getDocument(docType: String) {
        SVProgressHUD.show()
        DocumentApi.shared.getDocument(docType: docType, limit: limit,
                                       offset: arrDocument.count,
                                       searchText: searchTF.text ?? "",
                                       success: { [weak self] response in
                                        guard let self = self else { return }
                                        
                                        self.refreshControl.endRefreshing()
                                        if response.documents!.count < self.limit {
                                            self.isFinish = true
                                        }
                                        if self.arrDocument.isEmpty {
                                            self.arrDocument = response.documents ?? []
                                        } else {
                                            self.arrDocument.append(contentsOf: response.documents ?? [])
                                        }
                                        SVProgressHUD.dismiss()
                                        self.tableView.reloadData()
                                       }, failure: { code, errorMessage in
                                        SVProgressHUD.dismiss()
                                        self.tableView.reloadData()
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
    
    @objc func refresh() {
        arrDocument.removeAll()
        tableView.reloadData()
        getDocument(docType: documentType.rawValue)
    }
}

extension UploadClientVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrDocument.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! DocumentsTVCell
        cell.reloadData(document: arrDocument[indexPath.row], documentType: DocumentType(rawValue: documentType.rawValue)!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let file = arrDocument[indexPath.row]
        
        previewFile(file) { [weak self] previewItem, data in
            self?.urlPreviewItem = previewItem
            try! data.write(to: previewItem, options: .atomic)
            let previewVC = QLPreviewController()
            previewVC.dataSource = self
            self?.present(previewVC, animated: true, completion: nil)
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

extension UploadClientVC: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return urlPreviewItem! as QLPreviewItem
    }
}

extension UploadClientVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var imageName = ""
        let docImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        if picker.sourceType == .camera {
            imageName = "image_" + UUID().uuidString + ".jpeg"
        } else {
            let imagePath = (info[UIImagePickerController.InfoKey.imageURL] as? URL)!.absoluteString
            imageName = (imagePath as NSString).lastPathComponent
        }
        
        picker.dismiss(animated: true, completion: nil)
        
        let uploadVC = getVC(id: "DocumentUploadVC") as! DocumentUploadVC
        uploadVC.isFileImage = true
        uploadVC.imgFileName = imageName
        uploadVC.fileData = docImage.resize().pngData()
        customPresentViewController(presenter, viewController: uploadVC, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension UploadClientVC: SelectAccount {
    func selectAccount(_: Bool) {
        accountNameLbl.text = UserDefaultsHelper.shared.getClientName()
    }
}
