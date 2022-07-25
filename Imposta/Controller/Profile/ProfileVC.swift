//
//  ProfileVC.swift
//  Imposta
//
//  Created by Rovshen Shirinzade on 8/23/20.
//  Copyright © 2020 Imposta. All rights reserved.
//

import UIKit
import SDWebImage
import SVProgressHUD
import MarqueeLabel

class ProfileVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var accountNameLbl: MarqueeLabel!
    @IBOutlet weak var profilePhotoIV: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var surNameLbl: UILabel!
    @IBOutlet weak var phoneNumberLbl: UILabel!
    @IBOutlet weak var extentionLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var roleView: UIView!
    @IBOutlet weak var roleLbl: UILabel!
    @IBOutlet weak var extentionView: UIView!
    @IBOutlet weak var inviterView: UIView!
    @IBOutlet weak var inviterLbl: UILabel!
    @IBOutlet weak var onLogoIcon: UIImageView!
    @IBOutlet weak var logoNav: UIImageView!
    @IBOutlet weak var logoutIcon: UIImageView!
    
    var user: AuthUser?
    var profileModel: ProfileModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getProfileInfo()
        self.getProfilePicture()
        
        //        ProfileApi.shared.clientsList { result in
        //            print(result)
        //        } failure: { string in
        //            print(string)
        //        }

        //        ProfileApi.shared.receivedDocs { result in
        //            print("result.items: \(result.items?[0])")
        //        } failure: { string in
        //            print(string)
        //        }
                
        //        ProfileApi.shared.myUploads { result in
        //            print(result.items)
        //        } failure: { string in
        //            print(string)
        //        }
                
        //        ProfileApi.shared.sendInvitation(email: "a.sahib91@gmail.com") { auth in
        //            print(auth)
        //        } failure: { string in
        //            print(string)
        //        }
                
        //        ProfileApi.shared.changeCurrentAccount(clientId: 12) { string in
        //            print(string)
        //        } failure: { string in
        //            print(string)
        //        }
                
        //        ProfileApi.shared.MyDocsPreview(with: 21) { string in
        //            print(string)
        //        } failure: { string in
        //            print(string)
        //        }

        
        extentionLbl.text = ""
        roleLbl.isHidden = true
        inviterLbl.text = ""
        
        if GetUserType.user.isUserClient() {
        accountNameLbl.type = .continuous
        accountNameLbl.animationCurve = .easeInOut
        accountNameLbl.fadeLength = 10.0
        }
        
        setupLogo()
        self.inviterView.hideVerticalView()
        self.roleView.hideVerticalView()
        self.extentionView.hideVerticalView()

//        getUserProfile()
        user = AuthUser()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        accountNameLbl?.text = UserDefaultsHelper.shared.getClientName()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(getProfileInfo),
                                               name: NSNotification.Name("changeAccount"),
                                               object: nil)
    }
    
    func getUserProfile() {
        SVProgressHUD.show()
        AppApi.shared.getUserProfile(success: {
            response in
            
//            self.roleLbl.text = response.result?.role
            self.emailLbl.text = response.result?.emailAddress
            self.phoneNumberLbl.text = response.result?.phoneNumber
            self.surNameLbl.text = response.result?.lastName
            self.nameLbl.text = response.result?.firstName
            self.profilePhotoIV.showProfilePic(url: response.result?.profilePictureUrl ?? "")
            UserDefaultsHelper.shared.setUserProfileImageUrl(url: response.result?.profilePictureUrl ?? "")
            
            if GetUserType.user.isUserAdvisor() {
                self.extentionLbl.text = "\(response.result?.internalPhoneNumber ?? "")"
                
            } else { //client. employee doesn't have profile page
                self.extentionView.hideVerticalView()
                self.inviterLbl.text = response.result?.inviter
            }
            SVProgressHUD.dismiss()
        }, failure: {
            SVProgressHUD.dismiss()
        })
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
//
//                VC.delegate = self
//                let showPopup = SBCardPopupViewController(contentViewController: VC)
//                showPopup.show(onViewController: self)
//                SVProgressHUD.dismiss()
//            }, failure: {
//                SVProgressHUD.dismiss()
//            })
        }
    }
    
//    @IBAction func logoutBtnAction(_ sender: UIButton) {
//        let appDelegate = AppDelegate()
//        appDelegate.setRoot()
//    }

}

extension ProfileVC: SelectAccount {
    func selectAccount(_: Bool) {
        accountNameLbl?.text = UserDefaultsHelper.shared.getClientName()
    }
    
    func setupLogo() {
        onLogoIcon?.isUserInteractionEnabled = true
        logoNav?.isUserInteractionEnabled = true
        onLogoIcon?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onHome)))
        logoNav?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onHome)))
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
       

        
        
//        func logoutProfile() {
//            ProfileApi.shared.
//        }
}

extension ProfileVC {
    @objc func getProfileInfo() {
        ProfileApi.shared.getProfileInfo { model in
            print("here: \(model)")
            self.profileModel = model
            self.nameLbl.text = self.profileModel?.firstName
            self.surNameLbl.text = self.profileModel?.lastName
            self.phoneNumberLbl.text = self.profileModel?.phoneNumber
            self.emailLbl.text = self.profileModel?.emailAddress
            self.roleLbl.text = self.profileModel?.roles?[0]
        }
    }
    
    func getProfilePicture() {
        ProfileApi.shared.getProfilePicture { string in
            self.profilePhotoIV.image = UIImage.init(data: string)
            self.profilePhotoIV.contentMode = .scaleToFill
        }
    }
}
