//
//  ClientTVCell.swift
//  Imposta
//
//  Created by Rovshen Shirinzade on 8/24/20.
//  Copyright © 2020 Imposta. All rights reserved.
//

import UIKit

class ClientTVCell: UITableViewCell {
    
    @IBOutlet weak var photoIV: UIImageView!
    @IBOutlet weak var clientNameLbl: UILabel!
    @IBOutlet weak var accountOwnerLbl: UILabel!
    @IBOutlet weak var phoneNumberLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setup(client: Item) {
        print("phoneNumWWW: \(client.phoneNumber ?? "") \(client.fullName)")
        if client.clientType == Int(ClientType.Personal.rawValue) {
            photoIV.image = R.image.personalAccount()
            clientNameLbl.text = client.fullName
        } else {
            photoIV.image = R.image.businessAccount()
            clientNameLbl.text = client.fullName
        }

        phoneNumberLbl.text = client.phoneNumber
        accountOwnerLbl.text = "\(client.clientType ?? 0)"
//        if let creatorUser = client.creatorUser {
//            accountOwnerLbl.text = creatorUser.fullName
//        } else {
//            accountOwnerLbl.text = ""
//        }
    }

}
