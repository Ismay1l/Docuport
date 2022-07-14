//
//  LeftMenuCell.swift
//  Imposta
//
//  Created by Shamkhal Guliyev on 8/30/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit

class LeftMenuCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if self.isSelected {
            viewLine.isHidden = false
            lblTitle.textColor = UIColor(hexStr: "44BA8B", colorAlpha: 1)
            lblTitle.font = UIFont(name: "HelveticaNeue-Medium", size: 30)
        } else {
            viewLine.isHidden = true
            lblTitle.textColor = UIColor(hexStr: "C8C8C8", colorAlpha: 1)
            lblTitle.font = UIFont(name: "HelveticaNeue-Medium", size: 25)
        }
    }
}
