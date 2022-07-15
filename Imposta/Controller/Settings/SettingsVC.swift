//
//  SettingsVC.swift
//  Imposta
//
//  Created by Rovshen Shirinzade on 8/23/20.
//  Copyright © 2020 Imposta. All rights reserved.
//

import UIKit
import SVProgressHUD
import MarqueeLabel

class SettingsVC: UIViewController {
    
    @IBOutlet weak var accountNameLbl: MarqueeLabel!
    @IBOutlet weak var onLogoIcon: UIImageView!
    @IBOutlet weak var logoutIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLogo()
        
        accountNameLbl.type = .continuous
        accountNameLbl.animationCurve = .easeInOut
        accountNameLbl.fadeLength = 10.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        accountNameLbl.text = UserDefaultsHelper.shared.getClientName()
    }
    
    @IBAction func getInvite(_ sender: UIButton) {
        if let VC = R.storyboard.client.inviteVC() {
            self.navigationController?.pushViewController(VC, animated: true)
        }
    }
    
    @IBAction func getContact(_ sender: UIButton) {
        if let VC = R.storyboard.client.contactVC() {
            self.navigationController?.pushViewController(VC, animated: true)
        }
    }
    
    @IBAction func getBlog(_ sender: UIButton) {
        tryUrl(with: "https://numbersquad.com/blog/")
    }
    
    @IBAction func showAccountsAction(_ sender: UIButton) {
        if let VC = R.storyboard.client.accountsVC() {
            SVProgressHUD.show()
            
            AppApi.shared.getAllAccountNew { response in
                if let clients = response as? [AccountOnHeaderElement] {
                    print("accounts on header: \(clients)")
                    VC.arrUserNew = clients
                    VC.delegate = self
                    let showPopup = SBCardPopupViewController(contentViewController: VC)
                    showPopup.show(onViewController: self)
                    SVProgressHUD.dismiss()
                }
            } failure: {
                SVProgressHUD.dismiss()
            }
//            AppApi.shared.getAllAccount(success: { response in
//                guard let clients = response.result else { return }
//                VC.arrUser = clients
//                VC.delegate = self
//                let showPopup = SBCardPopupViewController(contentViewController: VC)
//                showPopup.show(onViewController: self)
//                SVProgressHUD.dismiss()
//            }, failure: {
//                SVProgressHUD.dismiss()
//            })
        }
    }
    

}

extension SettingsVC: SelectAccount {
    func selectAccount(_: Bool) {
        accountNameLbl.text = UserDefaultsHelper.shared.getClientName()
    }
    
    func setupLogo() {
        onLogoIcon.isUserInteractionEnabled = true
        onLogoIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onHome)))
        setLogout(view: logoutIcon)
    }
}

