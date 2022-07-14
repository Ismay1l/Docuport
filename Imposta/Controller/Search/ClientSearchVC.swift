//
//  ClientSearchVC.swift
//  Imposta
//
//  Created by Shamkhal Guliyev on 9/12/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol ClientSearchDelegate {
    func clientSearchReset()
    func clientSearchResult(clientSearch: ClientSearch)
}

class ClientSearchVC: UIViewController {

    @IBOutlet var txtFieldName: UITextField!
    @IBOutlet var txtFieldTIN: UITextField!
    @IBOutlet var txtFieldSNN: UITextField!
    @IBOutlet var txtFieldService: UITextField!
    @IBOutlet var segmendClientStatus: UISegmentedControl!
    @IBOutlet var buttonReset: UIButton!
    @IBOutlet var buttonSearch: UIButton!
    
    var strTitle: String?
    var toolbar = UIToolbar()
    var picker = UIPickerView()
    var clientSearch: ClientSearch?
    var arrClient = [ResultClients]()
    var delegate: ClientSearchDelegate?
    var arrService = [ClientServiceData]()
    //var arrService = ["bookkeepingtest", "Monthly Payroll", "taxtest", "Payrolltest"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        getAllServices()
    }
    
    func setup() {
        addTapGesture()
        clientSearch = ClientSearch()
        
        toolbar.sizeToFit()
        picker.delegate = self
        buttonReset.layer.borderWidth = 2
        buttonReset.layer.borderColor = UIColor(hexStr: "44BA8B", colorAlpha: 1).cgColor
    }
    
    func addPicker() {
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePicker))
        
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        
        txtFieldService.inputView = picker
        txtFieldService.inputAccessoryView = toolbar
    }
    
    @objc func donePicker() {
        txtFieldService.text = strTitle
        self.view.endEditing(true)
    }
    
    @objc func cancelPicker() {
        self.strTitle = ""        
        self.view.endEditing(true)
    }
    
    func getAllServices() {
        SVProgressHUD.show()
        AppApi.shared.getAllServices(success: { response in
            self.arrService = response.result!
            self.picker.reloadAllComponents()
            SVProgressHUD.dismiss()
        }, failure: {
            SVProgressHUD.dismiss()
            self.alert(title: "ERROR", message: "", actionButton: "OK")
        })
    }
    
    @IBAction func clientTypeSelection(_ sender: Any) {
        clientSearch?.clientType = segmendClientStatus.selectedSegmentIndex + 1
    }
    
    @IBAction func btnReset(_ sender: Any) {
        setup()
        txtFieldTIN.text = ""
        txtFieldSNN.text = ""
        txtFieldName.text = ""
        txtFieldService.text = ""
        delegate?.clientSearchReset()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSearch(_ sender: Any) {
        clientSearch?.tin = Int(txtFieldTIN.text!)
        clientSearch?.ssn = Int(txtFieldSNN.text!)
        clientSearch?.name = txtFieldName.text
        clientSearch?.clientType = segmendClientStatus.selectedSegmentIndex + 1
        delegate?.clientSearchResult(clientSearch: clientSearch!)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension ClientSearchVC: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrService.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arrService[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        strTitle = arrService[row].name
        clientSearch?.serviceId = arrService[row].id!
    }
}

extension ClientSearchVC: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtFieldService {
            addPicker()
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
