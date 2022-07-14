//
//  UploadTagsCell.swift
//  Imposta
//
//  Created by Huseyn Bayramov on 23.01.21.
//  Copyright © 2021 Imposta. All rights reserved.
//

import UIKit

class UploadTagsCell: UITableViewCell {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        icon.contentMode = .scaleAspectFit
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
