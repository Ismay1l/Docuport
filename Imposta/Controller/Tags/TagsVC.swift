//
//  TagsVC.swift
//  Imposta
//
//  Created by Huseyn Bayramov on 12.01.21.
//  Copyright © 2021 Imposta. All rights reserved.
//

import UIKit
import SVProgressHUD
import MarqueeLabel

class TagsVC: UIViewController {
    @IBOutlet weak var accountNameLbl: MarqueeLabel!
    @IBOutlet weak var advisorView: UIView!
    @IBOutlet weak var clientView: UIView!
    @IBOutlet weak var pageTitleLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var onLogoIcon: UIImageView!
    @IBOutlet weak var onLogoNav: UIImageView!
    @IBOutlet weak var logoutIcon: UIImageView!
    
    var pageTitle: String?
    var serviceId: Int?
    var iconColor: String?
//    var tagList: [Tag] = []
    var tagListNew: [TagGroupElement] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        pageTitleLbl.text = pageTitle
      
        setLogout(view: logoutIcon)
//        setupInteractions()
        
        print("clientType: \(GetUserType.user.isUserClient())")
        print(UserType.client.rawValue)
    
        
        if GetUserType.user.isUserClient() {
            print("clientType: \(GetUserType.user.isUserClient())")
            getTagsInfo()
            clientView.isHidden = false
        } else {
            print("clientType: \(GetUserType.user.isUserClient())")
            clientView.isHidden = true
            getTagsInfo()
        }
//            advisorView.isHidden = true
//        getTagsInfo()
//        clientView.isHidden = true
//        advisorView.isHidden = false
//        } else {
//            clientView.isHidden = true
//            getTagsForAdvisors()
//        }
    
        if GetUserType.user.isUserClient() {
        accountNameLbl.type = .continuous
        accountNameLbl.animationCurve = .easeInOut
        accountNameLbl.fadeLength = 10.0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        accountNameLbl.text = UserDefaultsHelper.shared.getClientName()
    }
}

extension TagsVC {
    func getTagsInfo() {
        guard let id = serviceId else {
            print("couldnt take id")
            return }
        print("id tag: \(id)")
        
        SVProgressHUD.show()
        DocumentApi.shared.getDocTypeTagsForClientNew(serviceId: id) { result in
            print("result tag: \(result)")
            if !result.isEmpty {
//                self.tagListNew.append(TagGroupElement(listIcon: result.first?.listIcon,
//                                                       id: result.first?.id,
//                                                       displayName: result.first?.displayName,
//                                                       isActive: result.first?.isActive,
//                                                       servicesItDepends: result.first?.servicesItDepends,
//                                                       tagGroupsItActivates: result.first?.tagGroupsItActivates,
//                                                       tagGroup: result.first?.tagGroup))
                self.tagListNew.append(contentsOf: result)
                self.collectionView.reloadData()
                SVProgressHUD.dismiss()
            }
        } failure: {
            print("error done")
            SVProgressHUD.dismiss()
        }

    }
    
//    func getTagsForClient() {
//        guard let id = serviceId else { return }
//
//        SVProgressHUD.show()
//        DocumentApi.shared.getDocTypeTagsForClient(serviceId: id, success: { result in
//            if !result.isEmpty {
//                self.tagList.append(Tag(id: -1, name: "All Tags", color: result[0].color, listIcon: result[0].listIcon))
//            }
//            self.tagList.append(contentsOf: result)
//            self.collectionView.reloadData()
//            SVProgressHUD.dismiss()
//        }, failure: {
//            SVProgressHUD.dismiss()
//        })
//    }
    

//    func getTagsForAdvisors() {
//        guard let id = serviceId else { return }
//
//        SVProgressHUD.show()
//        DocumentApi.shared.getDocTypeTagsForAdvisor(serviceId: id, success: { result in
//            if !result.isEmpty {
//                self.tagList.append(Tag(id: -1, name: "All Tags", color: result[0].color, listIcon: result[0].listIcon))
//            }
//            self.tagList.append(contentsOf: result)
//            self.collectionView.reloadData()
//            SVProgressHUD.dismiss()
//        }, failure: {
//            SVProgressHUD.dismiss()
//        })
//    }
    
    func setupInteractions() {
        onLogoNav.isUserInteractionEnabled = true
        onLogoIcon.isUserInteractionEnabled = true
        pageTitleLbl.isUserInteractionEnabled = true
        onLogoIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onHome)))
        onLogoNav.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onHome)))
        
        pageTitleLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backButtonAction(_:))))
    }
}


// MARK: - Collection View Methods
extension TagsVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagListNew.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listCell", for: indexPath) as! HomeListCVCell
        
        cell.iconImageView.image = convertBase64StringToImage(imageBase64String: tagListNew[indexPath.row].listIcon ?? "", mode: .alwaysTemplate)
//        if let color = iconColor
        cell.iconImageView.tintColor = UIColor.init(hexString: iconColor ?? "#ff0000")
        cell.titleLbl.text = tagListNew[indexPath.row].displayName
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemHeight: CGFloat = 84
        var itemWidth: CGFloat {
            return collectionView.frame.width
        }
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout  collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let id = tagListNew[indexPath.row].id else { return }
        let name = tagListNew[indexPath.row].displayName ?? ""
        onDocuments(service: HomePageService(listIcon: "", gridIcon: "", id: id, departmentID: 0, displayName: name, departmentDisplayName: "", color: ""), tagId: id)
    }
}


//Toggle
extension TagsVC {
    @IBAction func showAccountsAction(_ sender: UIButton) {
        if let VC = R.storyboard.client.accountsVC() {
            SVProgressHUD.show()
            AppApi.shared.getAllAccountNew { response in
                if let clients = response as? [AccountOnHeaderElement] {
                    VC.arrUserNew = clients
//                    VC.delegate = self
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
//                let showPopup = SBCardPopupViewController(contentViewController: VC)
//                showPopup.show(onViewController: self)
//                SVProgressHUD.dismiss()
//            }, failure: {
//                SVProgressHUD.dismiss()
//            })
        }
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        onBack()
    }
}

extension TagsVC: SelectAccount {
    func selectAccount(_: Bool) {
        accountNameLbl?.text = UserDefaultsHelper.shared.getClientName()
    }
}
