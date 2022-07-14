//
//  DocumentRealtedDocsVC.swift
//  Imposta
//
//  Created by Shamkhal on 11/17/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit
import SVProgressHUD
import XLPagerTabStrip



class DocumentRealtedDocsVC: UIViewController, IndicatorInfoProvider {
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var txtFieldSearch: UITextField!
    @IBOutlet weak var tableRelated: UITableView!
    @IBOutlet weak var buttonSave: UIButton!
    
    var clientId: Int?
    var isSearch = false
    var delegate: DocumentRelatedDelegate?
    var refreshControl = UIRefreshControl()
    
    var arrDocId = [Int]()
    var arrRelatedDocs = [DocumentRelatedDocs]()
    var arrRelatedDocsCopy = [DocumentRelatedDocs]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getClientRelatedDocs()
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Related docs")
    }
    
    func setup() {
        buttonSave.alpha = 0.5
        buttonSave.isEnabled = false
        getClientRelatedDocs()
        viewSearch.layer.cornerRadius = 10
        viewSearch.layer.shadowOpacity = 0.35
        viewSearch.layer.masksToBounds = false
        viewSearch.layer.shadowOffset = CGSize(width: 5, height: 5)
        viewSearch.layer.shadowColor = UIColor(hexStr: strColorCode, colorAlpha: 0.35).cgColor
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableRelated.addSubview(refreshControl)
    }
    
    @objc func refresh() {
        isSearch = false
        txtFieldSearch.text = ""
        arrRelatedDocs.removeAll()
        arrRelatedDocsCopy.removeAll()
        getClientRelatedDocs()
    }
    
    func getClientRelatedDocs() {
        if let idClient = DocumentSingleton.shared.clientId {
            SVProgressHUD.show()
            DocumentApi.shared.searchRelatedDoc(clientId: idClient, searchTerm: txtFieldSearch.text ?? "", success: { response in
                self.arrRelatedDocs.removeAll()
                self.arrRelatedDocs.append(DocumentRelatedDocs(id: -9999, docNumber: "-1", name: "No related docs", isSelected: false))
                if let docs = response.result, docs.count > 0 {
                    for item in docs {
                        var doc = item
                        doc.isSelected = false
                        self.arrRelatedDocs.append(doc)
                    }
                    if !self.isSearch {
                        self.arrRelatedDocsCopy = self.arrRelatedDocs
                    }                    
                }
                SVProgressHUD.dismiss()
                self.tableRelated.reloadData()
                self.refreshControl.endRefreshing()
            }, failure: {
                SVProgressHUD.dismiss()
                self.refreshControl.endRefreshing()
            })
        } else {
            self.alert(title: "WARNING", message: "Please, firstly select the client to get related documents", actionButton: "OK")
        }
    }
    
    func saveRelatedDocs() {
        arrRelatedDocsCopy.forEach { doc in
            if doc.isSelected == true {
                arrDocId.append(doc.id!)
            }
        }
        
        SVProgressHUD.show()
        DocumentApi.shared.saveRealtedDocs(documentId: editDocument?.id ?? 0, arrRelatedDocs: arrDocId, success: {
            self.alertWithHandler(title: "SUCCESS", message: "Document has successfully saved", actionButton: "OK", handler: {
                self.getClientRelatedDocs()
                DocumentSingleton.shared.isFileIploaded = true
                self.dismiss(animated: true, completion: nil)
                NotificationCenter.default.post(name: NSNotification.Name("documentSaved"), object: nil)
            })
            SVProgressHUD.dismiss()
        }, failure: {
            SVProgressHUD.dismiss()
        })
    }
    
    @IBAction func btnSave(_ sender: Any) {
        let clientId = DocumentSingleton.shared.clientId ?? 0
        let serviceId = DocumentSingleton.shared.serviceId ?? 0
        
        SVProgressHUD.show()
        DocumentApi.shared.saveDocumentClient(clientId: clientId, success: {
            DocumentApi.shared.saveDocumentClientService(docId: editDocument?.id ?? 0, serviceId: serviceId, success: {
                self.saveRelatedDocs()
                SVProgressHUD.dismiss()
            }, failure: {
                SVProgressHUD.dismiss()
            })
        }, failure: {
            SVProgressHUD.dismiss()
        })
    }
    
    @IBAction func btnClearSearch(_ sender: Any) {
        txtFieldSearch.text = ""
        getClientRelatedDocs()
    }
}

extension DocumentRealtedDocsVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        isSearch = true
        if txtFieldSearch.text!.isEmpty {
            arrRelatedDocs = arrRelatedDocsCopy
            tableRelated.reloadData()
        } else {
            getClientRelatedDocs()
        }
        textField.resignFirstResponder()
        
        return true
    }
}

extension DocumentRealtedDocsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrRelatedDocs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeEditCell") as! EmployeeEditCell
        
        if arrRelatedDocs[0].isSelected! && indexPath.row != 0 {
            cell.lblTitle.alpha = 0.5
            cell.isUserInteractionEnabled = false
        } else {
            cell.lblTitle.alpha = 1
            cell.isUserInteractionEnabled = true
        }
        
        cell.lblTitle.text = arrRelatedDocs[indexPath.row].name
        if let isSelected = arrRelatedDocs[indexPath.item].isSelected, isSelected == true {
            cell.backgroundColor = UIColor(hexStr: "44BA8B", colorAlpha: 0.15)
        } else {
            cell.setCellShadow()
            cell.backgroundColor = .clear
        }
        
        if indexPath.row == 0 {
            cell.setCellShadow()
            cell.backgroundColor = .clear
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            arrRelatedDocs[indexPath.row].isSelected = !arrRelatedDocs[indexPath.row].isSelected!
            for index in 0..<arrRelatedDocs.count {
                if index != 0 {
                    arrRelatedDocs[index].isSelected  = false
                }
            }
            
        } else {
            arrRelatedDocs[indexPath.row].isSelected = !arrRelatedDocs[indexPath.row].isSelected!
            if let idx = arrRelatedDocsCopy.firstIndex(where: { $0.id == arrRelatedDocs[indexPath.row].id }) {
                arrRelatedDocsCopy[idx].isSelected = arrRelatedDocs[indexPath.row].isSelected!
            }
        }
        tableRelated.reloadData()
        buttonSave.alpha = 1
        buttonSave.isEnabled = true
    }
}
