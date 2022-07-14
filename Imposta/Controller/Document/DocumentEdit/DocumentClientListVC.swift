//
//  DocumentClientListVC.swift
//  Imposta
//
//  Created by Shamkhal on 11/17/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit
import SVProgressHUD
import XLPagerTabStrip



class DocumentClientListVC: UIViewController, IndicatorInfoProvider {
    @IBOutlet weak var collectionClient: UICollectionView!
    @IBOutlet weak var buttonSave: UIButton!
    
    var isFinish = false
    var selectedClientIndex: Int?
    var arrClient = [ResultClients]()
    var delegate: DocumentClientDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonSave.alpha = 0.5
        buttonSave.isEnabled = false
        getClientList()
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Client")
    }
    
    func getClientList() {
        SVProgressHUD.show()
        ClientApi.shared.getClientList(limit: 20, offset: arrClient.count, success: { response in
            SVProgressHUD.dismiss()
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
                
                self.collectionClient.reloadData()
            }
        }, failure: {
            SVProgressHUD.dismiss()
        })
    }
    
    @IBAction func btnSave(_ sender: Any) {
        DocumentSingleton.shared.documentClientId = arrClient[selectedClientIndex!].id!
        delegate?.showServiceList(clientId: arrClient[selectedClientIndex!].id!)
    }
}

extension DocumentClientListVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrClient.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServiceCell", for: indexPath) as! ServiceCell
        
        if arrClient[indexPath.row].clientType == ClientType.Personal.rawValue {
            cell.imgType.image = UIImage(named: "personal")
            cell.lblTitle.text = arrClient[indexPath.row].fullClientName
        } else {
            cell.imgType.image = UIImage(named: "business")
            cell.lblTitle.text = arrClient[indexPath.row].name
        }
        
        if let isSelected = arrClient[indexPath.item].isSelected, isSelected == true {
            cell.backgroundColor = UIColor(hexStr: "44BA8B", colorAlpha: 0.15)
        } else {
            cell.setCellShadow()
            cell.backgroundColor = .clear
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let slctIndx = selectedClientIndex, slctIndx != indexPath.item  {
            arrClient[selectedClientIndex!].isSelected = false            
        }
        
        arrClient[indexPath.item].isSelected = true
        selectedClientIndex = indexPath.item
        collectionClient.reloadData()
        buttonSave.alpha = 1
        buttonSave.isEnabled = true
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !isFinish {
            if indexPath.item == arrClient.count - 1 {
                getClientList()
            }
        }
    }
}
