//
//  AccountsTVCell.swift
//  Imposta
//
//  Created by Rovshen Shirinzade on 8/23/20.
//  Copyright © 2020 Imposta. All rights reserved.
//

import UIKit

class AccountsTVCell: UITableViewCell {
    
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var checkImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func reloadCell(user: ResultClients) {
        if UserDefaultsHelper.shared.getClientID() == user.id {
            userPhotoImageView.borderColor = UIColor.init(hexString: "#0093FF")
            checkImageView.isHidden = false
            
            switch user.clientType {
            case ClientType.Business.rawValue:
                userNameLbl.text = user.name
                userPhotoImageView.sd_setImage(with: URL(string: user.profileImageUrl ?? ""), placeholderImage: UIImage(named: "account_business_selected"))
            case ClientType.Personal.rawValue:
                userNameLbl.text = user.fullClientName
                userPhotoImageView.sd_setImage(with: URL(string: user.profileImageUrl ?? ""), placeholderImage: UIImage(named: "account_personal_selected"))
            default:
                break
            }
        } else {
            userPhotoImageView.borderColor = .white
            checkImageView.isHidden = true
            
            
            switch user.clientType {
            case ClientType.Business.rawValue:
                userNameLbl.text = user.name
                userPhotoImageView.sd_setImage(with: URL(string: user.profileImageUrl ?? ""), placeholderImage: UIImage(named: "account_business"))
            case ClientType.Personal.rawValue:
                userNameLbl.text = user.fullClientName
                userPhotoImageView.sd_setImage(with: URL(string: user.profileImageUrl ?? ""), placeholderImage: UIImage(named: "account_personal"))
            default:
                break
            }
        }
        
//        switch user.clientType {
//        case ClientType.Business.rawValue:
//            userNameLbl.text = user.name
//            userPhotoImageView.sd_setImage(with: URL(string: user.profileImageUrl ?? ""), placeholderImage: UIImage(named: "account_business"))
//        case ClientType.Personal.rawValue:
//            userNameLbl.text = user.fullClientName
//            userPhotoImageView.sd_setImage(with: URL(string: user.profileImageUrl ?? ""), placeholderImage: UIImage(named: "account_personal"))
//        default:
//            break
//        }
        
    }

}

