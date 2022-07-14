//
//  UploadServicesClientVC.swift
//  Imposta
//
//  Created by Rovshen Shirinzade on 9/14/20.
//  Copyright © 2020 Imposta. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SVProgressHUD

class UploadServicesClientVC: UIViewController, SBCardPopupContent, IndicatorInfoProvider {

    var popupViewController: SBCardPopupViewController?
    var allowsTapToDismissPopupCard = false
    var allowsSwipeToDismissPopupCard = false
    
    @IBOutlet weak var wrapperHeight: NSLayoutConstraint!
    @IBOutlet weak var centerView: CardView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    var delegate: ServiceListDelegate?
    var document: ResultDocument?
    var arrService = [ClientServiceResult]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wrapperHeight.constant = self.view.frame.size.height

        setup()
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "UploadServicesClient")
    }
    
    func setup() {
        ClientApi.shared.getClientServiceList(clientId: "\(UserDefaultsHelper.shared.getClientID())", success: { response in
            guard let result = response.result else { return }
            self.arrService = result
            for index in 0..<self.arrService.count {
                self.arrService[index].service?.isSelected = false
            }
            
            if let idx = self.arrService.firstIndex(where: {$0.service?.id == self.document?.service?.id}) {
                self.arrService[idx].service?.isSelected = true
            }
            
            self.tableView.reloadData()
            SVProgressHUD.dismiss()
        }, failure: {
            SVProgressHUD.dismiss()
        })
    }
    
}

extension UploadServicesClientVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrService.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.uploadServicesClientTVCell.identifier, for: indexPath) as! UploadServicesClientTVCell
        
        cell.titleLbl.text = arrService[indexPath.item].service?.name
        if (arrService[indexPath.item].service?.isSelected)! {
            cell.backgroundColor = UIColor(hexString: "#F0F0F0")
        } else {
            cell.backgroundColor = .clear
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.serviceSelection(clientService: arrService[indexPath.item].service ?? ClientServiceData())
    }
}
