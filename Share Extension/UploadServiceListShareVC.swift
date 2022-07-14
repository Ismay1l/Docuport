//
//  UploadServiceListVC.swift
//  Imposta
//
//  Created by Rovshen Shirinzade on 9/20/20.
//  Copyright © 2020 Imposta. All rights reserved.
//

import UIKit
//import SVProgressHUD
//import XLPagerTabStrip

class UploadServiceListShareVC: UIViewController {
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonSave: UIButton!
    
    var clientId, serviceId: Int?
    var delegate: DocumentRelatedDelegate?
    var arrClientService = [ClientServiceResult]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.stopAnimating()
        spinner.hidesWhenStopped = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        buttonSave.alpha = 0.5
        buttonSave.isEnabled = false
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(true)
           self.view.endEditing(true)
       }
    
    func getClientServices() {
        self.showSpinner(self.spinner)
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
            }
            self.hideSpinner(self.spinner)
        }, failure: {
            self.hideSpinner(self.spinner)
        })
    }
    
    
    @IBAction func btnSave(_ sender: Any) {
        DocumentSingleton.shared.serviceId = serviceId ?? 0
        self.delegate?.showDesc(active: true)
    }

}

extension UploadServiceListShareVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrClientService.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UploadServicesClientTVCell", for: indexPath) as! UploadServicesClientTVCell
        
        cell.titleLbl.text = arrClientService[indexPath.item].service?.name
        
        if let isSelected = arrClientService[indexPath.item].service?.isSelected, isSelected == true {
            cell.backgroundColor = #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1)
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
        cell.backgroundColor = #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1)
        DocumentSingleton.shared.serviceId = serviceId ?? 0
        self.delegate?.showDesc(active: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        serviceId = arrClientService[indexPath.item].service?.id
        let cell = tableView.cellForRow(at: indexPath) as! UploadServicesClientTVCell
        cell.backgroundColor = .white
    }
    
}
