//
//  HomeVC.swift
//  Imposta
//
//  Created by Rovshen Shirinzade on 8/23/20.
//  Copyright © 2020 Imposta. All rights reserved.
//

import UIKit
import SVProgressHUD
import MarqueeLabel
import Updates

class HomeVC: UIViewController {
    
    @IBOutlet weak var accountNameLbl: MarqueeLabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var onLogoIcon: UIImageView!
    @IBOutlet weak var logoutIcon: UIImageView!
    
    var isGridFlowLayoutUsed: Bool = false
    var servicesList: [ClientServiceData] = []
    var servicesListNew: [HomePageService] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
        
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        isGridFlowLayoutUsed = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadServices(notification:)), name: .changeAccount, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(documentUpload), name: .documentSaved, object: nil)
        

//        setLogout(view: logoutIcon)
        
        if GetUserType.user.isUserClient() {
        accountNameLbl.type = .continuous
        accountNameLbl.animationCurve = .easeInOut
        accountNameLbl.fadeLength = 10.0
        }
        checkPayrollService()
        
        print("accessToken : \(UserDefaultsHelper.shared.getToken())")
        
        configureUpdates()
        configureLabels()
        observeAppVersionDidChange()
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        accountNameLbl.text = UserDefaultsHelper.shared.getClientName()
        
        

        Updates.configurationURL = Bundle.main.url(forResource: "Updates", withExtension: "json")
        
//        print("Updates.configurationURL \(Updates.configurationURL)")
//        print("Updates.updatingMode \(Updates.updatingMode)")
        Updates.updatingMode = .manually
        Updates.notifying = .always
        Updates.appStoreId = "1487430075"
        Updates.comparingVersions = .major
        Updates.minimumOSVersion = "11.0.0"
        Updates.versionString = "2.3.3"
//        print(Updates.appStoreId)
//        print("Updates.appStoreId")
        Updates.checkForUpdates { result in
                   UpdatesUI.promptToUpdate(result, presentingViewController: self)
            print("Updates.checkForUpdates")
//                   self.activityIndicator.stopAnimating()
               }
    }
    
    
    override func didReceiveMemoryWarning() {
          super.didReceiveMemoryWarning()
      }
      
      
      private func observeAppVersionDidChange() {
          NotificationCenter.default.addObserver(self, selector: #selector(appDidInstall),
          name: .appDidInstall, object: nil)
          NotificationCenter.default.addObserver(self, selector: #selector(appVersionDidChange),
                                                 name: .appVersionDidChange, object: nil)
      }
      
      @objc func appDidInstall(_ notification: Notification) {
          print("App installed.")
      }
      
      @objc func appVersionDidChange(_ notification: Notification) {
          print("App version changed.")
      }
}

//Funcs
extension HomeVC {
    @objc func reloadServices(notification: NSNotification) {
        setup()
    }
    
    func setup() {
        SVProgressHUD.show()
        servicesList.removeAll()
        print(GetUserType.user.isUserClient())
        print("userType: \(UserDefaultsHelper.shared.getUserType())")
        if UserType.client.rawValue == UserDefaultsHelper.shared.getUserType() {
            ClientApi.shared.getClientServiceListNew(clientId: "\(UserDefaultsHelper.shared.getClientID())") { response in
                if let result = response as? [ClientServices] {
                    print(result)
                    let array = result.map { service in
                        return HomePageService(listIcon: service.listIcon, gridIcon: service.gridIcon, id: service.id, departmentID: service.departmentID, displayName: service.displayName, departmentDisplayName: service.departmentDisplayName, color: service.color)
                    }
                    self.servicesListNew = array
                    print("count: \(self.servicesListNew.count)")
                    let myUploads = HomePageService(listIcon: "iconGridUploads", gridIcon: "iconGridUploads", id: 0, departmentID: 0, displayName: "My Uploads", departmentDisplayName: "My Uploads", color: "#007AFF")
                    self.servicesListNew.append(myUploads)
                    print("count: \(self.servicesListNew.count)")
                    self.collectionView.reloadData()
                    SVProgressHUD.dismiss()
                }
            } failure: {
                SVProgressHUD.dismiss()
            }

        }
        else {
            AppApi.shared.getAllServicesNew { response in
                if response != nil {
                    self.servicesListNew = response
                    let myUploads = HomePageService(listIcon: "iconGridUploads", gridIcon: "iconGridUploads", id: 0, departmentID: 0, displayName: "My Uploads", departmentDisplayName: "My Uploads", color: "#007AFF")
                    self.servicesListNew.append(myUploads)
                    self.collectionView.reloadData()
                    SVProgressHUD.dismiss()
                }
            } failure: {
                SVProgressHUD.dismiss()
            }
//            UserType.Client.rawValue == UserDefaultsHelper.shared.getUserType() {
//            ClientApi.shared.getClientServiceList(clientId: "\(UserDefaultsHelper.shared.getClientID())", success: { response in
//                guard let result = response.result else { return }
//                for item in result {
//                    if let service = item.service {
//                        self.servicesList.append(service)
//                    }
//                }
//                self.servicesList.append(ClientServiceData(id: 0, name: "My uploads", department: nil, isSelected: false, listIcon: nil, gridIcon: nil, color: "#0093FF", isMyUploads: true))
//
//                self.collectionView.reloadData()
//
//                SVProgressHUD.dismiss()
//            }, failure: {
//                SVProgressHUD.dismiss()
//            })
//        }
        
       
            

            //MARK: Client decoding error
            
            

//            AppApi.shared.getAllServices(success: { response in
//                guard let result = response.result else { return }
//                self.servicesList = result
//                self.servicesList.append(ClientServiceData(id: 0, name: "My uploads", department: nil, isSelected: false, listIcon: nil, gridIcon: nil, color: "#0093FF", isMyUploads: true))
//                self.collectionView.reloadData()
//                SVProgressHUD.dismiss()
//            }, failure: {
//                SVProgressHUD.dismiss()
//            })
        }
        
    }
    
    @objc func documentUpload() {
        if let controller = R.storyboard.main.documentsVC() {
            documentType = .outbox
            controller.pageTitle = "My uploads"
            if let navController = self.navigationController {
                navController.pushViewController(controller, animated: true)
            } else {
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true)
            }
        }
    }
}

//Toggle
extension HomeVC {
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
    
}

extension HomeVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return servicesListNew.count 
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        
        let cardCell = collectionView.dequeueReusableCell(withReuseIdentifier: "gridCell", for: indexPath) as! HomeListCVCell
        
        if indexPath.row == self.servicesListNew.count - 1 {
            cardCell.iconImageView.image = UIImage.init(named: self.servicesListNew[indexPath.row].gridIcon!)
        } else {
            cardCell.iconImageView.image = convertBase64StringToImage(imageBase64String: servicesListNew[indexPath.row].gridIcon ?? "" )
        }
        cardCell.titleLbl.text = servicesListNew[indexPath.row].departmentDisplayName
        
        cardCell.bgView?.backgroundColor = UIColor.init(hexString: servicesListNew[indexPath.row].color ?? "" )
        cardCell.bgView?.shadowColor = UIColor.init(hexString: servicesListNew[indexPath.row].color ?? "" ).withAlphaComponent(0.35)
        cell = cardCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var itemWidth: CGFloat {
            return collectionView.frame.width / 2 - 10
        }
        let itemHeight: CGFloat = itemWidth / 1.47 + 20
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout  collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == servicesListNew.count-1 {
//            onDocuments(service: servicesListNew[indexPath.row])
            if let VC = R.storyboard.main.documentsVC() {
                
                VC.isUploadsCell = true
                
                
                if let navController = self.navigationController {
                    navController.pushViewController(VC, animated: true)
                } else {
                    VC.modalPresentationStyle = .fullScreen
                    self.present(VC, animated: true)
                }
            }
        } else {
            onTags(index: indexPath.row)
        }
//        if indexPath.row == self.servicesListNew.count - 1 {
//            myUploads()
//        } else {
//            onDocuments(service: self.servicesListNew[indexPath.row])
//        }
        
        
    }
    
}

// MARK: - Methods
extension HomeVC {
    private func onTags(index: Int) {
        let controller = initController(with: "Main", withIdentifier: "TagsVC") as! TagsVC
        controller.pageTitle = servicesListNew[index].displayName
        controller.serviceId = servicesListNew[index].id
        controller.iconColor = servicesListNew[index].color
        if let navController = self.navigationController {
            navController.pushViewController(controller, animated: true)
        } else {
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true)
        }
    }
}

extension HomeVC: SelectAccount {
    func selectAccount(_: Bool) {
        accountNameLbl.text = UserDefaultsHelper.shared.getClientName()
    }
    
    func checkPayrollService() {
        PayrollApi.shared.hasPayrollService(success: {}, failure: { [weak self] in
            self?.tabBarController?.viewControllers?.remove(at: 2)
        })
    }
}


private extension HomeVC {
    
    func configureLabels() {
        let versionString: String? = Updates.versionString
        let buildString: String? =  Updates.buildString
        if let version = versionString, let build = buildString {
//            versionLabel.text = "App version: \(version)(\(build))"
        }
    }
    
    func configureUpdates() {
        // - Add custom configuration here if needed -
        // Updates.bundleIdentifier = ""
        // Updates.countryCode = ""
        // Updates.versionString = ""
    }
    
}
