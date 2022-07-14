//
//  EmployeeEditNewVC.swift
//  Imposta
//
//  Created by Rovshen Shirinzade on 9/8/20.
//  Copyright © 2020 Imposta. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol EmployeeEditDelegate {
    func employeeSelection(employee: ClientEmployee)
}

class EmployeeEditNewVC: UIViewController, SBCardPopupContent {

    @IBOutlet weak var wrapperViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var titleLbl: UILabel!
    
    var popupViewController: SBCardPopupViewController?
    let allowsTapToDismissPopupCard = false
    let allowsSwipeToDismissPopupCard = false
    
    var pageTitle: String?
    
    var departmentId: Int?
    var delegate: EmployeeEditDelegate?
    var arrEmployee = [ClientEmployee]()
    var selectedEmployee: ClientEmployee?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLbl.text = pageTitle
        wrapperViewHeight.constant = self.view.frame.size.height
        setup()
        
    }
    
    func setup() {
        SVProgressHUD.show()
        AppApi.shared.getServiceEmployee(departId: departmentId ?? 0, success: { response in
            guard let result = response.result else { return }
            self.arrEmployee = result
            self.tableView.reloadData()
            SVProgressHUD.dismiss()
        }, failure: {
            SVProgressHUD.dismiss()
        })
    }
    
    @IBAction func saveBtnAction(_ sender: UIButton) {
        if (selectedEmployee != nil) {
            delegate?.employeeSelection(employee: selectedEmployee!)
        }
        popupViewController?.close()
    }
    
}

extension EmployeeEditNewVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let itemCount = arrEmployee.count
        tableViewHeight.constant = CGFloat(itemCount * 66)
        return itemCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectServicesTVCell", for: indexPath) as! SelectServicesTVCell
        cell.titleLbl.text = arrEmployee[indexPath.item].fullName
        if arrEmployee[indexPath.item].isSelected ?? false {
            cell.backgroundColor = UIColor(hexString: "#F0F0F0")
        } else {
            cell.backgroundColor = .white
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedEmployee = arrEmployee[indexPath.row]
        
        for index in 0...(arrEmployee.count - 1)  {
            arrEmployee[index].isSelected = false
        }
        arrEmployee[indexPath.row].isSelected = true
        tableView.reloadData()
    }
}
