//
//  EmployeeEditVC.swift
//  Imposta
//
//  Created by Shamkhal on 11/16/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit
import TagListView
import SVProgressHUD

class EmployeeEditVC: UIViewController {

    @IBOutlet weak var tagView: TagListView!
    @IBOutlet weak var tableEmployee: UITableView!
    @IBOutlet weak var buttonSave: UIButton!
    
    var departmentId: Int?
    var delegate: EmployeeEditDelegate?
    var arrEmployee = [ClientEmployee]()
    var selectedEmployee: ClientEmployee?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    func setup() {
        tagView.delegate = self
        tagView.enableRemoveButton = false
        buttonSave.isHidden = true
        
        SVProgressHUD.show()
        AppApi.shared.getServiceEmployee(departId: departmentId ?? 0, success: { response in
            guard let result = response.result else { return }
            self.arrEmployee = result
            self.tableEmployee.reloadData()
            SVProgressHUD.dismiss()
        }, failure: {
            SVProgressHUD.dismiss()
        })
    }
    
    @IBAction func btnSave(_ sender: Any) {
        delegate?.employeeSelection(employee: selectedEmployee!)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension EmployeeEditVC: TagListViewDelegate {
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        
    }
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        sender.removeTagView(tagView)
    }
}

extension EmployeeEditVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrEmployee.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeEditCell") as! EmployeeEditCell
        
        cell.lblTitle.text = arrEmployee[indexPath.row].fullName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        buttonSave.isHidden = false
        selectedEmployee = arrEmployee[indexPath.row]
        tagView.removeAllTags()
        tagView.addTag(arrEmployee[indexPath.row].fullName ?? "")
        tableEmployee.reloadData()
    }
}
