//
//  DocumentSearchVC.swift
//  Imposta
//
//  Created by Shamkhal Guliyev on 9/10/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit
import SVProgressHUD

class DocumentSearchVC: UIViewController {

    @IBOutlet var txtFieldName: UITextField!
    @IBOutlet var txtFieldClient: UITextField!
    @IBOutlet var txtFieldService: UITextField!
    @IBOutlet var txtFieldDuetDate: UITextField!
    @IBOutlet var txtFieldCreatedTime: UITextField!
    @IBOutlet weak var txtFieldRelatedDocs: UITextField!
    @IBOutlet weak var viewRelatedDocs: UIView!
    @IBOutlet var segmendDocStatus: UISegmentedControl!
    @IBOutlet var buttonReset: UIButton!
    @IBOutlet var buttonSearch: UIButton!
    @IBOutlet weak var clientView: UIView!
    @IBOutlet weak var clientViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var relatedDocsHeighConstraint: NSLayoutConstraint!
    @IBOutlet weak var popupViewHeightConstraint: NSLayoutConstraint!
    
    var toolbar = UIToolbar()
    var picker = UIPickerView()
    var datePicker = UIDatePicker()
    var pickerType = PickerType.client
    
    var isClient = false
    var strTitle: String?
    var selectedClientId: Int?
    var isClientSelected = false
    var documentSearch = DocumentSearch()
    
    var arrClient = [ResultClients]()
    var arrDocument = [ResultDocument]()
    var arrService = [ClientServiceData]()
    var arrClientService = [ClientServiceResult]()
    var arrRelateDocs = [DocumentRelatedDocs]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func setup() {
        toolbar.sizeToFit()
        picker.delegate = self
        
        getService()
        addTapGesture()
        
        switch UserDefaultsHelper.shared.getUserType() {
        case UserType.advisor.rawValue, UserType.employee.rawValue:
            getClientList()
            
            if documentType == .inbox {
                viewRelatedDocs.isHidden = true
                relatedDocsHeighConstraint.constant = 0
                popupViewHeightConstraint.constant = 340
            } else {
                viewRelatedDocs.isHidden = false
                relatedDocsHeighConstraint.constant = 40
                popupViewHeightConstraint.constant = 380
            }
            clientView.isHidden = false
            clientViewHeightConstraint.constant = 40
            
        case UserType.client.rawValue:
            isClient = true
            if documentType == .inbox {
                viewRelatedDocs.isHidden = false
                relatedDocsHeighConstraint.constant = 40
                popupViewHeightConstraint.constant = 340
            } else {
                viewRelatedDocs.isHidden = true
                relatedDocsHeighConstraint.constant = 0
                popupViewHeightConstraint.constant = 300
            }
            clientView.isHidden = true
            clientViewHeightConstraint.constant = 0
            selectedClientId = UserDefaultsHelper.shared.getClientID()
        default:
            break
        }
        
        buttonReset.layer.borderWidth = 2
        buttonReset.layer.borderColor = UIColor(hexStr: "44BA8B", colorAlpha: 1).cgColor
    }
    
    func getClientList() {
        SVProgressHUD.show()
        ClientApi.shared.getClientList(limit: 200, offset: arrClient.count, success: { response in
            if response.result != nil {
                self.arrClient = (response.result?.clients)!
                self.picker.reloadAllComponents()
            } else {
                self.alertWithHandler(title: (response.error?.message)!, message: (response.error?.details)!, actionButton: "OK", handler: {})
            }
            
            SVProgressHUD.dismiss()
        }, failure: {
            SVProgressHUD.dismiss()
        })
    }
    
    func getService() {
        SVProgressHUD.show()
        if !isClient {
            AppApi.shared.getAllServices(success: { response in
                if let result = response.result {
                    self.arrService = result
                    self.picker.reloadAllComponents()
                }
                SVProgressHUD.dismiss()
            }, failure: {
                SVProgressHUD.dismiss()
            })
        } else {
            ClientApi.shared.getClientServiceList(clientId: "\(UserDefaultsHelper.shared.getClientID())", success: { response in
                guard let result = response.result else { return }
                self.arrClientService = result
                self.picker.reloadAllComponents()
                SVProgressHUD.dismiss()
            }, failure: {
                SVProgressHUD.dismiss()
            })
        }
    }
    
    func addPicker() {
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePicker))
        
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        
        txtFieldClient.inputView = picker
        txtFieldClient.inputAccessoryView = toolbar
        
        txtFieldService.inputView = picker
        txtFieldService.inputAccessoryView = toolbar
        
        txtFieldRelatedDocs.inputView = picker
        txtFieldRelatedDocs.inputAccessoryView = toolbar
    }
    
    func addDatePicker() {
        datePicker.datePickerMode = .date
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneDatePicker))
        
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        
        txtFieldCreatedTime.inputView = datePicker
        txtFieldCreatedTime.inputAccessoryView = toolbar
    }
    
    @objc func doneDatePicker() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        txtFieldCreatedTime.text = formatter.string(from: datePicker.date)
        documentSearch.creationTime = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker() {
        self.view.endEditing(true)
    }
    
    @objc func donePicker() {
        if pickerType == .client {
            isClientSelected = true
            txtFieldClient.text = strTitle
        } else if pickerType == .service {
            txtFieldService.text = strTitle
        } else if pickerType == .relatedDocs {
            txtFieldRelatedDocs.text = strTitle
        }
        
        self.view.endEditing(true)
    }
    
    @objc func cancelPicker() {
        self.strTitle = ""
        
        self.view.endEditing(true)
    }
    
    @IBAction func segmentAction(_ sender: Any) {
        if segmendDocStatus.selectedSegmentIndex != 4 {
            documentSearch.status = segmendDocStatus.selectedSegmentIndex + 1
        }
    }
    
    @IBAction func btnReset(_ sender: Any) {
        setup()
        txtFieldName.text = ""
        txtFieldClient.text = ""
        txtFieldService.text = ""
        txtFieldDuetDate.text = ""
        txtFieldCreatedTime.text = ""
        
        NotificationCenter.default.post(name: NSNotification.Name("documentReset"), object: nil)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSearch(_ sender: Any) {
        let userInfo: [String: DocumentSearch] = ["searchDoc": documentSearch]
        NotificationCenter.default.post(name: NSNotification.Name("documentSearch"), object: nil, userInfo: userInfo)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension DocumentSearchVC: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerType == .client {
            return arrClient.count
        } else if pickerType == .service {
            if isClient {
                return arrClientService.count
            } else {
                return arrService.count
            }
        } else if pickerType == .relatedDocs {
            return arrRelateDocs.count
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerType == .client {
            return arrClient[row].name
        } else if pickerType == .service {
            if isClient {
                return arrClientService[row].service?.name
            } else {
                return arrService[row].name
            }
        } else if pickerType == .relatedDocs {
            return arrRelateDocs[row].name
        } else {
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerType == .client {
            strTitle = arrClient[row].name
            selectedClientId = arrClient[row].id!
            documentSearch.clientId = arrClient[row].id
        } else if pickerType == .service {
            if isClient {
                strTitle = arrClientService[row].service?.name
                documentSearch.serviceId = arrClientService[row].service?.id
            } else {
                strTitle = arrService[row].name
                documentSearch.serviceId = arrService[row].id
            }
        } else if pickerType == .relatedDocs {
            strTitle = arrRelateDocs[row].name
            documentSearch.relatedDocId = arrRelateDocs[row].id
        }
    }
}

extension DocumentSearchVC: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtFieldClient {
            pickerType = .client
            addPicker()
            
        } else if textField == txtFieldService {
            pickerType = .service
            addPicker()
            
        } else if textField == txtFieldCreatedTime {
            addDatePicker()
            
        } else if textField == txtFieldRelatedDocs {
            pickerType = .relatedDocs
            addPicker()
            if let id = selectedClientId {
                DocumentApi.shared.searchRelatedDoc(clientId: id, searchTerm: "", success: { response in
                    if response.result != nil {
                        self.arrRelateDocs = response.result!
                        self.picker.reloadAllComponents()
                    } else {
                        self.alertWithHandler(title: (response.error?.message)!, message: (response.error?.details)!, actionButton: "OK", handler: {})
                    }
                }, failure: {})
            } else {
                alert(title: "Firstly, you have to select client to get related documents", message: "", actionButton: "OK")
            }
        }
        
        return true
    }
}
