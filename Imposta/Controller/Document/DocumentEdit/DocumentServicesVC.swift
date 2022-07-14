//
//  DocumentServicesVC.swift
//  Imposta
//
//  Created by Shamkhal on 11/17/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit
import SVProgressHUD
import XLPagerTabStrip

protocol DocumentServiceDelegate {
    func showRelatedDocs()
}

class DocumentServicesVC: UIViewController, IndicatorInfoProvider {
    @IBOutlet weak var collectionService: UICollectionView!
    @IBOutlet weak var buttonSave: UIButton!
    
    var clientId, serviceId: Int?
    var delegate: DocumentServiceDelegate?
    var arrClientService = [ClientServiceResult]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                
                self.collectionService.reloadData()
            }
            SVProgressHUD.dismiss()
        }, failure: {
            SVProgressHUD.dismiss()
        })
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Services")
    }
    
    @IBAction func btnSave(_ sender: Any) {
        DocumentSingleton.shared.serviceId = serviceId!
        self.delegate?.showRelatedDocs()
    }
}

extension DocumentServicesVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrClientService.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServiceCell", for: indexPath) as! ServiceCell
        
        cell.setCellShadow()
        cell.lblTitle.text = arrClientService[indexPath.item].service?.name
        
        if let isSelected = arrClientService[indexPath.item].service?.isSelected, isSelected == true {
            cell.backgroundColor = UIColor(hexStr: "44BA8B", colorAlpha: 0.15)
        } else {
            cell.setCellShadow()
            cell.backgroundColor = .clear
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        buttonSave.alpha = 1
        buttonSave.isEnabled = true
        
        print("Service qaqa")
        serviceId = arrClientService[indexPath.item].service?.id
        let cell = collectionView.cellForItem(at: indexPath) as! ServiceCell
        cell.backgroundColor = UIColor(hexStr: "44BA8B", colorAlpha: 0.15)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        serviceId = arrClientService[indexPath.item].service?.id
        let cell = collectionView.cellForItem(at: indexPath) as! ServiceCell
        cell.backgroundColor = .white
    }
}
