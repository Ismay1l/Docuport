//
//  DocumentsUploadCell.swift
//  Imposta
//
//  Created by Nihad Ismayilov on 09.07.22.
//  Copyright © 2022 Imposta. All rights reserved.
//

import UIKit

class DocumentsUploadCell: UITableViewCell {

    @IBOutlet var uploadImage: UIView!
    @IBOutlet var uploadTitle: UILabel!
    @IBOutlet var uploadView: UIView!
    @IBOutlet var uploadFinancialStatement: UILabel!
    @IBOutlet var uploadQuarter: UILabel!
    @IBOutlet var uploadYear: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
