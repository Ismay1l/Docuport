//
//  SelectServiceVC.swift
//  Imposta
//
//  Created by Rovshen Shirinzade on 8/23/20.
//  Copyright © 2020 Imposta. All rights reserved.
//

import UIKit
import SVProgressHUD

class SelectServiceVC: UIViewController, SBCardPopupContent {

    @IBOutlet weak var wrapperViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var titleLbl: UILabel!
    
    var popupViewController: SBCardPopupViewController?
    let allowsTapToDismissPopupCard = true
    let allowsSwipeToDismissPopupCard = true
    
    var client: ResultClients?
    var document: ResultDocument?
    var delegate: ServiceListDelegate?
    var selectedService: ClientServiceData?
    var arrAllService = [ClientServiceData]()
    var allServices = [HomePageService]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wrapperViewHeight.constant = self.view.frame.size.height
        setup()
    }
    
    func setup() {
        arrAllService.removeAll()
        SVProgressHUD.show()
        
        AppApi.shared.getAllServicesNew { result in
            print(result)
            self.allServices = result
            self.tableView.reloadData()
            SVProgressHUD.dismiss()
        } failure: {
            print("Error")
        }
        
//        AppApi.shared.getAllServices(success: { response in
//            guard let result = response.result else { return }
//            for index in 0..<result.count {
//                self.arrAllService.append(result[index])
//                self.arrAllService[index].isSelected = false
//
//                if let _ = self.client?.services?.firstIndex(where: {$0.service?.id == result[index].id}) {
//                    self.arrAllService[index].isSelected = true
//                }
//            }
//            self.tableView.reloadData()
//            SVProgressHUD.dismiss()
//        }, failure: {
//            SVProgressHUD.dismiss()
//        })
    }
    
    @IBAction func saveBtnAction(_ sender: UIButton) {
        delegate?.clientServiceAndEmployee(client: client!)
        popupViewController?.close()
    }
    
}

extension SelectServiceVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let itemCount = arrAllService.count
        let itemCount = self.allServices.count
        tableViewHeight.constant = CGFloat(itemCount * 66)
        return itemCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectServicesTVCell", for: indexPath) as! SelectServicesTVCell
        cell.titleLbl.text = allServices[indexPath.row].displayName
        if allServices[indexPath.item].isSelected ?? false {
            cell.backgroundColor = UIColor(hexString: "#F0F0F0")
        } else {
            cell.backgroundColor = .white
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let VC = R.storyboard.advisor.employeeEditNewVC() {
//            selectedService = allServices[indexPath.row]
            let selection = (allServices[indexPath.row].isSelected) ?? false
            allServices[indexPath.item].isSelected = !selection
            
            VC.departmentId = allServices[indexPath.item].departmentID
            VC.delegate = self
            VC.pageTitle = self.allServices[indexPath.row].displayName
            let showPopup = SBCardPopupViewController(contentViewController: VC)
            showPopup.show(onViewController: self)
        }
    }
}

extension SelectServiceVC: EmployeeEditDelegate {
    func employeeSelection(employee: ClientEmployee) {
        
        let selectedIndex = client?.services?.index(where: {$0.service?.id == selectedService?.id}) ?? -1
        if selectedIndex != -1 {
            client?.services?.remove(at: selectedIndex)
        }

        client?.services?.append(ClientServiceResult(service: selectedService, employee: employee))
        setup()
        delegate?.clientServiceAndEmployee(client: client!)
    }
}
