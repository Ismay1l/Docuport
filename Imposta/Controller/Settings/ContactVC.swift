//
//  ContactVC.swift
//  Imposta
//
//  Created by Rovshen Shirinzade on 8/23/20.
//  Copyright © 2020 Imposta. All rights reserved.
//

import UIKit
import SVProgressHUD
import MarqueeLabel

class ContactVC: UIViewController {
    
    @IBOutlet weak var accountNameLbl: MarqueeLabel!
    @IBOutlet weak var advisorNameLbl: UILabel!
    @IBOutlet weak var advisorEmailLbl: UILabel!
    @IBOutlet weak var advisorPhoneNumberLbl: UILabel!
    @IBOutlet weak var technicalPhoneNumberLbl: UILabel!
    @IBOutlet weak var technicalEmailLbl: UILabel!
    @IBOutlet weak var companyWebSiteLbl: UILabel!
    @IBOutlet weak var onLogoIcon: UIImageView!
    @IBOutlet weak var privacyPolicyBtn: UIButton!
    @IBOutlet weak var termsLinkBtn: UIButton!
    @IBOutlet weak var refundPolicyBtn: UIButton!
    @IBOutlet weak var disclaimerBtn: UIButton!
    @IBOutlet weak var logoutIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        createLabelTap(tap: UITapGestureRecognizer(target: self, action: #selector(self.callAdvisor)), label: advisorPhoneNumberLbl)
        createLabelTap(tap: UITapGestureRecognizer(target: self, action: #selector(self.callTechnical)), label: technicalPhoneNumberLbl)
        privacyPolicyBtn.addTarget(self, action: #selector(privacyPolicyTap), for: .touchUpInside)
        termsLinkBtn.addTarget(self, action: #selector(termsTap), for: .touchUpInside)
        refundPolicyBtn.addTarget(self, action: #selector(refundsTap), for: .touchUpInside)
        disclaimerBtn.addTarget(self, action: #selector(disclaimerTap), for: .touchUpInside)
        
        accountNameLbl.type = .continuous
        accountNameLbl.animationCurve = .easeInOut
        accountNameLbl.fadeLength = 10.0
        
        setupLogo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        accountNameLbl.text = UserDefaultsHelper.shared.getClientName()
        
        advisorNameLbl.text = UserDefaults.getAccountInfo?.fullName
        advisorEmailLbl.text = UserDefaults.getAccountInfo?.emailAddress
        advisorPhoneNumberLbl.text = UserDefaults.getAccountInfo?.phoneNumber
    }
    
    @IBAction func showAccountsAction(_ sender: UIButton) {
        if let VC = R.storyboard.client.accountsVC() {
            SVProgressHUD.show()
            
            AppApi.shared.getAllAccountNew { response in
                if let clients = response as? [AccountOnHeaderElement] {
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
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

}

//Funcs
extension ContactVC {
    
    func createLabelTap(tap: UITapGestureRecognizer, label: UILabel) {
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tap)
    }
    
    @objc func callAdvisor(sender:UITapGestureRecognizer) {
        if let advisorPhoneNumber = advisorPhoneNumberLbl.text {
            guard let number = URL(string: "tel://"+getPhoneNumber(number: advisorPhoneNumber)) else { return }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(number)
            }
        }
    }

    @objc func callTechnical(sender:UITapGestureRecognizer) {
        if let technicalPhoneNumber = technicalPhoneNumberLbl.text {
            guard let number = URL(string: "tel://"+getPhoneNumber(number: technicalPhoneNumber)) else { return }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(number)
            }
        }
    }
    
    @objc func privacyPolicyTap() {
        tryUrl(with: Constants.Contact.privacyPolicyLink)
    }
    
    @objc func termsTap() {
        tryUrl(with: Constants.Contact.termsLink)
    }
    
    @objc func refundsTap() {
        tryUrl(with: Constants.Contact.refundsPolicyLink)
    }
    
    @objc func disclaimerTap() {
        tryUrl(with: Constants.Contact.disclaimerLink)
    }

//    @objc func callCompany(sender:UITapGestureRecognizer) {
//        if let companyPhoneNumber = companyPhoneNumberLbl.text {
//            guard let number = URL(string: "tel://"+getPhoneNumber(number: companyPhoneNumber)) else { return }
//            if #available(iOS 10.0, *) {
//                UIApplication.shared.open(number)
//            }
//        }
//    }
    
    func getPhoneNumber(number: String) -> String {
        return "+" + number.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
    }
}

extension ContactVC: SelectAccount {
    func selectAccount(_: Bool) {
        accountNameLbl.text = UserDefaultsHelper.shared.getClientName()
        
        advisorNameLbl.text = UserDefaults.getAccountInfo?.fullName
        advisorEmailLbl.text = UserDefaults.getAccountInfo?.emailAddress
        advisorPhoneNumberLbl.text = UserDefaults.getAccountInfo?.phoneNumber
    }
    
    func setupLogo() {
        onLogoIcon.isUserInteractionEnabled = true
        onLogoIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onHome)))
//        setLogout(view: logoutIcon)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onLogout))
                self.logoutIcon.isUserInteractionEnabled = true
                self.logoutIcon.addGestureRecognizer(gesture)
    }
    
    @objc func onLogout() {
                print(#function)
                ProfileApi.shared.logoutProfile { result in
                    print(result)
                }
            let appDelegate = AppDelegate()
            appDelegate.setRoot()
    //        setLogout(view: logoutIcon)
            print("gestured used")
        }
}

