//
//  AdvisorListVC.swift
//  Imposta
//
//  Created by Shamkhal on 11/16/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol AdvisorListDelegate {
    func advisorSelection(advisor: ClientAdvisor)
}

class AdvisorListVC: UIViewController {
    @IBOutlet weak var txtFieldSearch: UITextField!
    @IBOutlet weak var tableAdvisor: UITableView!
    @IBOutlet weak var buttonSave: UIButton!
    
    var delegate: AdvisorListDelegate?
    var selectedAdvisor: ClientAdvisor?
    var arrAdvisorList = [ClientAdvisor]()
    var arrAdvisorListCopy = [ClientAdvisor]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func setup() {
        buttonSave.isEnabled = false
        SVProgressHUD.show()
        ClientApi.shared.getAdvisorList(success: { response in
            if let list = response.result, list.count > 0 {
                for index in 0..<list.count {
                    self.arrAdvisorList.append(list[index])
                    self.arrAdvisorList[index].isSelected = false
                }
            }
            self.arrAdvisorListCopy = self.arrAdvisorList
            
            self.tableAdvisor.reloadData()
            SVProgressHUD.dismiss()
        }, failure: {
            SVProgressHUD.dismiss()
        })
    }
    
    func resetSearch() {
        txtFieldSearch.text = ""
        arrAdvisorList = arrAdvisorListCopy
        tableAdvisor.reloadData()
    }
    
    @IBAction func btnResetSearch(_ sender: Any) {
        resetSearch()
    }
    
    @IBAction func btnSave(_ sender: Any) {
        delegate?.advisorSelection(advisor: selectedAdvisor!)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension AdvisorListVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrAdvisorList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeEditCell") as! EmployeeEditCell
        
        cell.lblTitle.text = arrAdvisorList[indexPath.row].fullName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        arrAdvisorList[indexPath.row].isSelected = !arrAdvisorList[indexPath.row].isSelected!
        if let idx = arrAdvisorListCopy.firstIndex(where: { $0.id == arrAdvisorList[indexPath.row].id }) {
            arrAdvisorListCopy[idx].isSelected = arrAdvisorList[indexPath.row].isSelected!
        }
        let cell = tableView.cellForRow(at: indexPath) as! EmployeeEditCell
        cell.backgroundColor = UIColor(hexStr: "44BA8B", colorAlpha: 0.15)
        selectedAdvisor = arrAdvisorList[indexPath.item]
        buttonSave.isEnabled = true
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        arrAdvisorList[indexPath.row].isSelected = !arrAdvisorList[indexPath.row].isSelected!
        if let idx = arrAdvisorListCopy.firstIndex(where: { $0.id == arrAdvisorList[indexPath.row].id }) {
            arrAdvisorListCopy[idx].isSelected = arrAdvisorList[indexPath.row].isSelected!
        }
        let cell = tableView.cellForRow(at: indexPath) as! EmployeeEditCell
        cell.setCellShadow()
        cell.backgroundColor = .clear
    }
}

extension AdvisorListVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string == "" {
            resetSearch()
            
            return true
        }
        arrAdvisorList.removeAll()
        arrAdvisorList = arrAdvisorListCopy.filter({ advisor -> Bool in
            return (advisor.fullName?.lowercased().contains(textField.text! + string))!
        })
        
        tableAdvisor.reloadData()
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
