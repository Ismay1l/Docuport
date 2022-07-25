//
//  SwitchVC.swift
//  Imposta
//
//  Created by Shamkhal Guliyev on 9/19/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit
import SVProgressHUD

class SwitchVC: UIViewController {
    @IBOutlet var tableSwitch: UITableView!
    @IBOutlet var viewSwitch: UIView!
    @IBOutlet var viewHeightConstraint: NSLayoutConstraint!
    
    var arrUser = [ResultClients]()
    var arrUserNew = [AccountOnHeaderElement]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func setup() {
        SVProgressHUD.show()
        
        AppApi.shared.getAllAccountNew { response in
            if let clients = response as? [AccountOnHeaderElement] {
                self.arrUserNew = clients
//                VC.delegate = self
                self.tableSwitch.reloadData()
//                let showPopup = SBCardPopupViewController(contentViewController: VC)
//                showPopup.show(onViewController: self)
                SVProgressHUD.dismiss()
            }
        } failure: {
            SVProgressHUD.dismiss()
        }
        
//        AppApi.shared.getAllAccount(success: { response in
//            guard let clients = response.result else { return }
//            self.arrUser = clients
//            self.tableSwitch.reloadData()
//            SVProgressHUD.dismiss()
//        }, failure: {
//            SVProgressHUD.dismiss()
//        })
        viewSwitch.roundCorners(corners: [.topLeft, .topRight], radius: 30)
    }
}

extension SwitchVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrUserNew.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchUserCell") as! SwitchUserCell
        cell.reloadCell(user: arrUserNew[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let userId = arrUserNew[indexPath.item].id else { return }
        UserDefaultsHelper.shared.setClientID(id: userId)
        dismiss(animated: true, completion: nil)
    }
}
