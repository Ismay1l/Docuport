//
//  ClientDetailVC.swift
//  Imposta
//
//  Created by Shamkhal Guliyev on 9/13/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit
import SDWebImage

class ClientDetailVC: UIViewController {
    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var lblFullname: UILabel!
    @IBOutlet var lblAccount: UILabel!
    @IBOutlet var lblServices: UILabel!
    @IBOutlet var lblAddress: UILabel!
    
    var strDocs = ""
    var client: ResultClients?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }    
    
    func setup() {
        if client?.services?.count ?? 0 > 0 {
            for service in client!.services! {
                strDocs.append(service.service!.name!)
                strDocs.append(",")
            }
            
            lblServices.text = strDocs
        }
        
        lblAddress.text = client?.fullAddress
        lblAccount.text = client?.creatorUser?.fullName
        lblFullname.text = "\(client?.firstName ?? "") \(client?.lastName ?? "")"
        
        imgProfile.layer.borderWidth = 2
        imgProfile.layer.borderColor = UIColor(hexStr: "44BA8B", colorAlpha: 1).cgColor
        guard let profileImg = client?.profileImageUrl else { return }
//        imgProfile.sd_setImage(with: URL(string: profileImg)!)
        imgProfile.showProfilePic(url: profileImg)
    }
    
    @IBAction func btnEdit(_ sender: Any) {
        editClient = client
        presentNavFullScreen(id: "clientEditNav")
    }
    
    @IBAction func btnClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
