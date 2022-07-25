//
//  AccountsVC.swift
//  Imposta
//
//  Created by Rovshen Shirinzade on 8/23/20.
//  Copyright © 2020 Imposta. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol SelectAccount: class {
    func selectAccount(_: Bool)
}

class AccountsVC: UIViewController, SBCardPopupContent {
    
    @IBOutlet weak var wrapperViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    var popupViewController: SBCardPopupViewController?
    let allowsTapToDismissPopupCard = false
    let allowsSwipeToDismissPopupCard = false
    
    var delegate: SelectAccount? = nil
    
//    var arrUser = [ResultClients]()
    var arrUserNew = [AccountOnHeaderElement]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wrapperViewHeight.constant = self.view.frame.size.height
        let contentHeight = CGFloat(arrUserNew.count * 62)
        if contentHeight > UIScreen.main.bounds.height - 240 {
            tableViewHeight.constant = UIScreen.main.bounds.height - 240
        } else {
            tableViewHeight.constant = contentHeight
        }
    }
    
    @IBAction func closeBtnAction(_ sender: UIButton) {
        popupViewController?.close()
    }
}

extension AccountsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let itemCount = arrUserNew.count
        
        return itemCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountsTVCell", for: indexPath) as! AccountsTVCell
        cell.reloadCell(user: arrUserNew[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let userId = arrUserNew[indexPath.item].id else { return }
        UserDefaultsHelper.shared.setClientID(id: userId)
        
        if let advisor = arrUserNew[indexPath.row].advisor {
            UserDefaults.setAccountInfo(advisor)
        }
        
        switch arrUserNew[indexPath.item].clientType {
        case 1:
            UserDefaultsHelper.shared.setClientName(name: arrUserNew[indexPath.item].name ?? "")
        case 2:
            UserDefaultsHelper.shared.setClientName(name: arrUserNew[indexPath.item].name ?? "")
        default:
            break
        }

        NotificationCenter.default.post(name: .changeAccount, object: nil)
        delegate?.selectAccount(true)
        
        popupViewController?.close()
        moveToRootController()
    }
}
