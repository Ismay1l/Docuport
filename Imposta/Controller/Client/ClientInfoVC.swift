//
//  ClientInfoVC.swift
//  Imposta
//
//  Created by Rovshen Shirinzade on 8/23/20.
//  Copyright © 2020 Imposta. All rights reserved.
//

import UIKit
import SVProgressHUD

class ClientInfoVC: UIViewController, SBCardPopupContent {
    
    @IBOutlet weak var wrapperViewHeight: NSLayoutConstraint!
    @IBOutlet weak var clientNameLbl: UILabel!
    @IBOutlet weak var clientAddressLbl: UILabel!
    @IBOutlet weak var clientServicesLbl: UILabel!
    @IBOutlet weak var clientOwnerLbl: UILabel!
    @IBOutlet weak var clientPhotoIV: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    
    var clientBusiness: ClientInfoUser1?
    var clientPersonal: ClientInfoUser2?
    
    var id: Int?
    var clientType: Int?
    var clientServices: ServiceBusiness?
    
    var popupViewController: SBCardPopupViewController?
    let allowsTapToDismissPopupCard = false
    let allowsSwipeToDismissPopupCard = false

    override func viewDidLoad() {
//        clientType = clientPersonal?.clientType ?? 1
        super.viewDidLoad()
        wrapperViewHeight.constant = self.view.frame.size.height
        
        if UserDefaultsHelper.shared.getUserType() == UserType.employee.rawValue {
            editButton.isHidden = true
        }
        bindModel()
        
        NotificationCenter.default.addObserver(self, selector: #selector(closePopup(notification:)), name: .closePopup, object: nil)
        
    }
    
    func bindModel() {
        if clientType == 1 {
            
            clientNameLbl.text = "\(clientBusiness?.name ?? "")"
            clientOwnerLbl.text = clientBusiness?.ownerUser
            clientAddressLbl.text = clientBusiness?.emailAddress
//            self.clientServicesLbl.text = self.clientServices?.displayName
            self.id = clientBusiness?.id
            self.getPic(id: clientBusiness?.id ?? 0)
            
            if clientBusiness?.services?.count ?? 0 > 0 {
                var clientServices = ""
                for service in clientBusiness!.services! {
                    clientServices.append(service.displayName ?? "")
                    clientServices.append(", ")
                }
                clientServicesLbl.text = clientServices
            }
//            print("nameQQQ: \(client?.name ?? "")")
        } else if clientType == 2 {
            clientNameLbl.text = "\(clientPersonal?.firstName ?? "") \(clientPersonal?.lastName ?? "")"
            clientOwnerLbl.text = clientPersonal?.ownerUser
            clientAddressLbl.text = clientPersonal?.emailAddress
            self.id = clientPersonal?.id
            self.getPic(id: clientPersonal?.id ?? 0)
            
            if clientPersonal?.services?.count ?? 0 > 0 {
                var clientServices = ""
                for service in clientPersonal!.services! {
                    clientServices.append(service.displayName ?? "")
                    clientServices.append(", ")
                }
                clientServicesLbl.text = clientServices
            }
            
            if clientPersonal?.hasProfilePicture ?? false {
//                clientPhotoIV.showProfilePic(url: )
                clientPhotoIV.contentMode = .scaleAspectFill
            }
//            print("nameQQQ: \(client?.name)")
        }
//        clientNameLbl.text = client?.name ?? ""
        
//        guard let profileImg = client?.profileImageUrl else { return }
       
    }
    
    @objc func closePopup(notification: NSNotification) {
        popupViewController?.close()
    }
    
    @IBAction func closePopupAction(_ sender: UIButton) {
        popupViewController?.close()
    }
    
    @IBAction func editButtonAction(_ sender: UIButton) {
        if clientType == 1 {
            editClientBusiness = clientBusiness
        } else if clientType == 2 {
            editClientPersonal = clientPersonal
        }
//        let vc = ClientInfoEditVC()
        UserDefaults.standard.set(self.clientType, forKey: "clientType")
        UserDefaults.standard.set(self.id, forKey: "editId")
        presentNavFullScreen1(id: "clientEditNVC")
    }
    
}

extension ClientInfoVC {
    func getPic(id: Int) {
        SVProgressHUD.show()
        ClientApi.shared.getClientPicByIDBusiness(id: id) { data in
            self.clientPhotoIV.image = UIImage.init(data: data)
            SVProgressHUD.dismiss()
        } failure: { string in
            print(string)
        }

    }
}
