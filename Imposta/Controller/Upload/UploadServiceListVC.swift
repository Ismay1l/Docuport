//
//  UploadServiceListVC.swift
//  Imposta
//
//  Created by Rovshen Shirinzade on 9/20/20.
//  Copyright © 2020 Imposta. All rights reserved.
//

import UIKit
import SVProgressHUD
import XLPagerTabStrip

class UploadServiceListVC: UIViewController, IndicatorInfoProvider {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonSave: UIButton!
    
    var clientId, serviceId: Int?
    var delegate: DocumentRelatedDelegate?
    var arrClientService = [ClientServiceResult]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getClientServices()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        buttonSave.alpha = 0.5
        buttonSave.isEnabled = false
        getClientServices()
    }
    
    func getClientServices() {
        SVProgressHUD.show()
        ClientApi.shared.getClientServiceList(clientId: "\(DocumentSingleton.shared.clientId ?? 0)", success: { response in
            if response.result!.count > 0 {
                self.buttonSave.isHidden = false
                self.arrClientService = response.result!
                
                if let idx = self.arrClientService.firstIndex(where: {$0.service?.id == editDocument?.service?.id}) {
                    self.buttonSave.alpha = 1
                    self.buttonSave.isEnabled = true
                    self.serviceId = self.arrClientService[idx].service?.id
                    self.arrClientService[idx].service?.isSelected = true
                }
                
                self.tableView.reloadData()
            }else {
                self.arrClientService = []
                self.tableView.reloadData()
            }
            SVProgressHUD.dismiss()
        }, failure: {
            SVProgressHUD.dismiss()
        })
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "ServiceList")
    }
    
    @IBAction func btnSave(_ sender: Any) {
        DocumentSingleton.shared.serviceId = serviceId ?? 0
        self.delegate?.showTags()
    }

}

extension UploadServiceListVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrClientService.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.uploadServicesClientTVCell.identifier, for: indexPath) as! UploadServicesClientTVCell
        
        cell.titleLbl.text = arrClientService[indexPath.item].service?.name
        
        if let isSelected = arrClientService[indexPath.item].service?.isSelected, isSelected == true {
            cell.backgroundColor = UIColor(hexString: "#F0F0F0")
        } else {
            cell.backgroundColor = .clear
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        buttonSave.alpha = 1
        buttonSave.isEnabled = true
        serviceId = arrClientService[indexPath.item].service?.id
        let cell = tableView.cellForRow(at: indexPath) as! UploadServicesClientTVCell
        cell.backgroundColor = UIColor(hexString: "#F0F0F0")
        DocumentSingleton.shared.serviceId = serviceId ?? 0
        self.delegate?.showTags()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        serviceId = arrClientService[indexPath.item].service?.id
        let cell = tableView.cellForRow(at: indexPath) as! UploadServicesClientTVCell
        cell.backgroundColor = .white
    }
    
}
