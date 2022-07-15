//
//  DocumentsVC.swift
//  Imposta
//
//  Created by Rovshen Shirinzade on 8/23/20.
//  Copyright © 2020 Imposta. All rights reserved.
//

import UIKit
import QuickLook
import SVProgressHUD
import MarqueeLabel

class DocumentsVC: UIViewController {
    
    @IBOutlet weak var accountNameLbl: MarqueeLabel!
    @IBOutlet weak var advisorView: UIView!
    @IBOutlet weak var clientView: UIView!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var gridButton: UIButton!
    @IBOutlet weak var pageTitleLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var topView: CardView!
    @IBOutlet weak var logoIcon: UIImageView!
    @IBOutlet weak var logoutIcon: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    
    var isGridFlowLayoutUsed: Bool = false
    
    var limit = 50
    var isFinish = false, isSearch = false
    var pageTitle: String?
    var serviceId: Int?
    var tagId: Int = -1
    
    var myUploads: MyUploadsResponse?
    
    var showSearchView = false
    
    var searchDocument: DocumentSearch?
    var arrDocument = [ResultDocument]()
    var arrDocumentCopy = [ResultDocument]()
    var refreshControl = UIRefreshControl()
    
    var urlPreviewItem: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        pageTitleLbl.text = pageTitle
        
        listButton.tintColor = .white
        listButton.isHidden = true
        gridButton.tintColor = UIColor.init(hexString: "#E1E1E1")
        gridButton.isHidden = true
        
        searchView.isHidden = true
        searchTF.addTarget(self, action: #selector(searchText(_:)), for: .editingChanged)
        
        if GetUserType.user.isUserClient() {
            advisorView.isHidden = true
        } else {
            clientView.isHidden = true
        }
        
        if GetUserType.user.isUserClient() {
        accountNameLbl.type = .continuous
        accountNameLbl.animationCurve = .easeInOut
        accountNameLbl.fadeLength = 10.0
        }
        
        setup()
        setupInteractions()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDocuments(notification:)), name: .changeAccount, object: nil)
        
        topView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideSearchView)))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        accountNameLbl.text = UserDefaultsHelper.shared.getClientName()
    }
    
}

//Toggles
extension DocumentsVC {
    @IBAction func showAccountsAction(_ sender: UIButton) {
        searchTF.resignFirstResponder()
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

    @IBAction func listButtonAction(_ sender: UIButton) {
        listButton.tintColor = .white
        listButton.backgroundColor = UIColor.init(hexString: "#E1E1E1")
        gridButton.backgroundColor = .clear
        gridButton.tintColor = UIColor.init(hexString: "#E1E1E1")
        isGridFlowLayoutUsed = false
        tableView.reloadData()
    }

    @IBAction func gridButtonAction(_ sender: UIButton) {
        listButton.backgroundColor = .clear
        listButton.tintColor = UIColor.init(hexString: "#E1E1E1")
        gridButton.backgroundColor = UIColor.init(hexString: "#E1E1E1")
        gridButton.tintColor = .white
        isGridFlowLayoutUsed = true
        tableView.reloadData()
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        onBack()
    }

    @IBAction func searchBtnAction(_ sender: UIButton) {
        if showSearchView {
            searchView.isHidden = true
            pageTitleLbl.isHidden = false
            backButton.isHidden = false
            showSearchView = false
            view.endEditing(true)
        } else {
            searchView.isHidden = false
            pageTitleLbl.isHidden = true
            backButton.isHidden = true
            showSearchView = true
            searchTF.becomeFirstResponder()
            searchTF.text = ""
        }
    }
    
    @objc private func searchText(_ textfield: UITextField) {
        refresh()
    }
    
    @IBAction func shareBtnAction(_ sender: UIButton) {
        hideSearchView()
        let row = arrDocument.index(where: { $0.id == sender.tag }) ?? 0
        let file = arrDocument[row]
        shareFile(file)
    }
}

//Funcs
extension DocumentsVC {
    fileprivate func setup() {
        searchDocument = DocumentSearch()
        searchType = .documents
        getDocument(docType: documentType.rawValue)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
        setupLogo()
    }
    
    func getDocument(docType: String) {
        SVProgressHUD.show()
        DocumentApi.shared.getDocument(docType: docType, limit: limit,
                                       offset: arrDocument.count, serviceId: serviceId,
                                       tagId: tagId,
                                       searchText: searchTF.text ?? "", isSearch: isSearch,
                                       success: { response in
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
    
    private func setupInteractions() {
        pageTitleLbl.isUserInteractionEnabled = true
        pageTitleLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backButtonAction(_:))))
        backButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backButtonAction(_:))))
    }
    
    @objc func refresh() {
        arrDocument.removeAll()
        tableView.reloadData()
        getDocument(docType: documentType.rawValue)
    }
    
    @objc func reloadDocuments(notification: NSNotification) {
        searchTF.text = ""
        showSearchView = false
        refresh()
    }
    
    @objc func hideSearchView() {
        searchView.isHidden = true
        showSearchView = false
        searchTF.resignFirstResponder()
    }
}

extension DocumentsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrDocument.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if isGridFlowLayoutUsed {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "gridCell", for: indexPath) as! DocumentsTVCell
//            return cell
//        } else {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! DocumentsTVCell
        
//        if documentType == .inbox {
//            cell.getUploads(uploads: (self.myUploads?.items?[indexPath.row])!)
//        } else {
            if GetUserType.user.isUserClient() {
                cell.reloadData(document: arrDocument[indexPath.row], documentType: DocumentType(rawValue: documentType.rawValue)!)
            } else {
                cell.reloadData(document: arrDocument[indexPath.row], documentType: DocumentType(rawValue: documentType.rawValue)!)
            }
//        }
        
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        hideSearchView()
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

extension DocumentsVC: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return urlPreviewItem! as QLPreviewItem
    }
}

extension DocumentsVC: SelectAccount {
    func selectAccount(_: Bool) {
        accountNameLbl.text = UserDefaultsHelper.shared.getClientName()
    }
    
    func setupLogo() {
        logoIcon.isUserInteractionEnabled = true
        logoIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onHome)))
        setLogout(view: logoutIcon)
    }
}


