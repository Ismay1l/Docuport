//
//  ClientInfoVC.swift
//  Imposta
//
//  Created by Rovshen Shirinzade on 8/23/20.
//  Copyright © 2020 Imposta. All rights reserved.
//

import UIKit

class ClientInfoVC: UIViewController, SBCardPopupContent {
    
    @IBOutlet weak var wrapperViewHeight: NSLayoutConstraint!
    @IBOutlet weak var clientNameLbl: UILabel!
    @IBOutlet weak var clientAddressLbl: UILabel!
    @IBOutlet weak var clientServicesLbl: UILabel!
    @IBOutlet weak var clientOwnerLbl: UILabel!
    @IBOutlet weak var clientPhotoIV: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    
    var client: ResultClients?
    
    var popupViewController: SBCardPopupViewController?
    let allowsTapToDismissPopupCard = false
    let allowsSwipeToDismissPopupCard = false

    override func viewDidLoad() {
        super.viewDidLoad()
        wrapperViewHeight.constant = self.view.frame.size.height
        
        if UserDefaultsHelper.shared.getUserType() == UserType.Employee.rawValue {
            editButton.isHidden = true
        }
        bindModel()
        
        NotificationCenter.default.addObserver(self, selector: #selector(closePopup(notification:)), name: .closePopup, object: nil)
    }
    
    func bindModel() {
        if client?.clientType == ClientType.Business.rawValue {
            clientNameLbl.text = client?.name
        } else if client?.clientType == ClientType.Personal.rawValue {
            clientNameLbl.text = "\(client?.firstName ?? "") \(client?.lastName ?? "")"
        }
        clientOwnerLbl.text = client?.creatorUser?.fullName
        clientAddressLbl.text = client?.emailAddress
        
        if client?.services?.count ?? 0 > 0 {
            var clientServices = ""
            for service in client!.services! {
                clientServices.append(service.service!.name!)
                clientServices.append(",")
            }
            clientServicesLbl.text = clientServices
        }
//        guard let profileImg = client?.profileImageUrl else { return }
        if let profileImg = client?.profileImageUrl {
            clientPhotoIV.showProfilePic(url: profileImg)
            clientPhotoIV.contentMode = .scaleAspectFill
        }
    }
    
    @objc func closePopup(notification: NSNotification) {
        popupViewController?.close()
    }
    
    @IBAction func closePopupAction(_ sender: UIButton) {
        popupViewController?.close()
    }
    
    @IBAction func editButtonAction(_ sender: UIButton) {
        editClient = client
        presentNavFullScreen1(id: "clientEditNVC")
    }
}
