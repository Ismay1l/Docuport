//
//  DownloadCell.swift
//  Imposta
//
//  Created by Shamkhal Guliyev on 9/5/19.
//  Copyright © 2019 Imposta. All rights reserved.
//

import UIKit

class DownloadCell: UITableViewCell {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var lblFileName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet var lblService: UILabel!
    @IBOutlet var lblAccount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
