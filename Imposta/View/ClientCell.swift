//
//  ClientCell.swift
//  Imposta
//
//  Created by Shamkhal Guliyev on 9/3/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit

class ClientCell: UITableViewCell {

    @IBOutlet var lblClientId: UILabel!
    @IBOutlet var view: UIView!
    @IBOutlet var lblService: UILabel!
    @IBOutlet var lblAccount: UILabel!
    @IBOutlet var imgClient: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
