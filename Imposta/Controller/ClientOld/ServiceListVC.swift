//
//  ServiceListVC.swift
//  Imposta
//
//  Created by Shamkhal on 11/15/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit
import SVProgressHUD

class ServiceListVC: UIViewController {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var collectionServiceList: UICollectionView!
        
    var isFromFileUpload = false
    
    var client: ResultClients?
    var document: ResultDocument?
    var delegate: ServiceListDelegate?
    var selectedService: ClientServiceData?
    var arrService = [ClientServiceResult]()
    var arrAllService = [ClientServiceData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func setup() {
        SVProgressHUD.show()
        if isFromFileUpload {
            ClientApi.shared.getClientServiceList(clientId: "\(UserDefaultsHelper.shared.getClientID())", success: { response in
                guard let result = response.result else { return }
                self.arrService = result
                for index in 0..<self.arrService.count {
                    self.arrService[index].service?.isSelected = false
                }
                
                if let idx = self.arrService.firstIndex(where: {$0.service?.id == self.document?.service?.id}) {
                    self.arrService[idx].service?.isSelected = true
                }
                
                self.collectionServiceList.reloadData()
                SVProgressHUD.dismiss()
            }, failure: {
                SVProgressHUD.dismiss()
            })
        } else {
            AppApi.shared.getAllServices(success: { response in
                guard let result = response.result else { return }
                for index in 0..<result.count {
                    self.arrAllService.append(result[index])
                    self.arrAllService[index].isSelected = false
                    
                    if let _ = self.client?.services?.firstIndex(where: {$0.service?.id == result[index].id}) {
                        self.arrAllService[index].isSelected = true
                    }
                }
                self.collectionServiceList.reloadData()
                SVProgressHUD.dismiss()
            }, failure: {
                SVProgressHUD.dismiss()
            })
        }
    }
    
    @IBAction func btnSave(_ sender: Any) {
//        delegate?.serviceSelection(clientService: selectedService ?? ClientServiceData())        
    }
    
    @IBAction func btnBack(_ sender: Any) {
        if isFromFileUpload {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}

extension ServiceListVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFromFileUpload {
            return arrService.count
        } else {
            return arrAllService.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServiceCell", for: indexPath) as! ServiceCell
        
        if isFromFileUpload {
            cell.lblTitle.text = arrService[indexPath.item].service?.name
            if (arrService[indexPath.item].service?.isSelected)! {
                cell.backgroundColor = UIColor(hexStr: "44BA8B", colorAlpha: 0.15)
            } else {
                cell.backgroundColor = .clear
            }
        } else {
            cell.lblTitle.text = arrAllService[indexPath.item].name
            if arrAllService[indexPath.item].isSelected! {
                cell.backgroundColor = UIColor(hexStr: "44BA8B", colorAlpha: 0.15)
            } else {
                cell.backgroundColor = .clear
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isFromFileUpload {
            dismiss(animated: true, completion: nil)
            delegate?.serviceSelection(clientService: arrService[indexPath.item].service ?? ClientServiceData())
        } else {
            selectedService = arrAllService[indexPath.item]
            let selection = (arrAllService[indexPath.item].isSelected)!
            arrAllService[indexPath.item].isSelected = !selection
            
            let employeeVC = getVC(id: "EmployeeEditVC") as! EmployeeEditVC
            employeeVC.departmentId = arrAllService[indexPath.item].department?.id
            employeeVC.delegate = self
            show(employeeVC, sender: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40)
    }
}

extension ServiceListVC: EmployeeEditDelegate {
    func employeeSelection(employee: ClientEmployee) {
        client?.services?.append(ClientServiceResult(service: selectedService, employee: employee))
        setup()
        delegate?.clientServiceAndEmployee(client: client!)
        navigationController?.popViewController(animated: true)
    }
}
