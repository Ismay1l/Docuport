//
//  UploadClientListVC.swift
//  Imposta
//
//  Created by Rovshen Shirinzade on 9/20/20.
//  Copyright © 2020 Imposta. All rights reserved.
//

import UIKit
//import XLPagerTabStrip
//import SVProgressHUD

class UploadClientListShareVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var buttonSave: UIButton!
    
    var isFinish = false
    var selectedClientIndex: Int?
    var arrClient = [ResultClients]()
    var delegate: DocumentClientDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.stopAnimating()
        spinner.hidesWhenStopped = true
        buttonSave.alpha = 0.5
        buttonSave.isEnabled = false
        getClientList()

    }
    
   
    
    func getClientList() {
        showSpinner(spinner)
        ClientApi.shared.getClientList(limit: 20, offset: arrClient.count, success: { response in
            self.hideSpinner(self.spinner)
            guard let clients = response.result?.clients else { return }
            if clients.count == 0 {
                self.isFinish = true
            } else {
                self.isFinish = false
                for client in clients {
                    self.arrClient.append(client)
                }
                if let idx = self.arrClient.firstIndex(where: {$0.id == editDocument?.client?.id}) {
                    self.selectedClientIndex = idx
                    self.buttonSave.alpha = 1
                    self.buttonSave.isEnabled = true
                    self.arrClient[idx].isSelected = true
                    DocumentSingleton.shared.clientId = self.arrClient[idx].id
                }
                
                self.tableView.reloadData()
            }
        }, failure: {
            self.hideSpinner(self.spinner)
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(true)
           self.view.endEditing(true)
       }
    
    @IBAction func btnSave(_ sender: Any) {
        DocumentSingleton.shared.documentClientId = arrClient[selectedClientIndex!].id!
        delegate?.showServiceList(clientId: arrClient[selectedClientIndex!].id!)
    }
}

extension UploadClientListShareVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrClient.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UploadServicesClientTVCell", for: indexPath) as! UploadServicesClientTVCell
        
        if arrClient[indexPath.row].clientType == ClientType.Personal.rawValue {
            cell.titleLbl.text = arrClient[indexPath.row].fullClientName
        } else {
            cell.titleLbl.text = arrClient[indexPath.row].name
        }
        
        if let isSelected = arrClient[indexPath.item].isSelected, isSelected == true {
            cell.backgroundColor = #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1)
        } else {
            cell.backgroundColor = .clear
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let slctIndx = selectedClientIndex, slctIndx != indexPath.item  {
            arrClient[selectedClientIndex!].isSelected = false
        }
        arrClient[indexPath.item].isSelected = true
        selectedClientIndex = indexPath.item
        tableView.reloadData()
        buttonSave.alpha = 1
        buttonSave.isEnabled = true
        DocumentSingleton.shared.documentClientId = arrClient[selectedClientIndex!].id!
        delegate?.showServiceList(clientId: arrClient[selectedClientIndex!].id!)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !isFinish {
            if indexPath.item == arrClient.count - 1 {
                getClientList()
            }
        }
    }
    
}

