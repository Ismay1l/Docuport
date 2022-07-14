//
//  InvitationCell.swift
//  Imposta
//
//  Created by Shamkhal Guliyev on 9/13/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit

class InvitationCell: UITableViewCell {
    
    @IBOutlet var lblDate: UILabel!
    @IBOutlet var view: UIView!
    @IBOutlet var lblAccount: UILabel!
    @IBOutlet var lblEmail: UILabel!
    @IBOutlet var viewSideColor: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
