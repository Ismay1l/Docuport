//
//  SwitchUserCell.swift
//  Imposta
//
//  Created by Shamkhal Guliyev on 9/19/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit

class SwitchUserCell: UITableViewCell {
    @IBOutlet var imgUser: UIImageView!
    @IBOutlet var lblUser: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func reloadCell(user: ResultClients) {
        if UserDefaultsHelper.shared.getClientID() == user.id {
            lblUser.textColor = UIColor(hexStr: "44BA8B", colorAlpha: 1)
        } else {
            lblUser.textColor = UIColor(hexStr: "C8C8C8", colorAlpha: 1)
        }
        
        switch user.clientType {
        case ClientType.Business.rawValue:
            lblUser.text = user.name
            imgUser.sd_setImage(with: URL(string: user.profileImageUrl ?? ""), placeholderImage: UIImage(named: "business"))
        case ClientType.Personal.rawValue:
            lblUser.text = user.fullClientName
            imgUser.sd_setImage(with: URL(string: user.profileImageUrl ?? ""), placeholderImage: UIImage(named: "personal"))
        default:
            break
        }
        
        imgUser.layer.cornerRadius = 20 //width constraint/2
        imgUser.layer.borderWidth = 2
        imgUser.layer.borderColor = UIColor(hexStr: "44BA8B", colorAlpha: 1).cgColor
    }
}
