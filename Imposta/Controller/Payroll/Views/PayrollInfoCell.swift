//
//  PayrollInfoCell.swift
//  Imposta
//
//  Created by Huseyn Bayramov on 27.02.21.
//  Copyright © 2021 Imposta. All rights reserved.
//

import UIKit.UICollectionViewCell

class PayrollInfoCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: PayrollTextField!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(viewModel: PayrollInfoCellViewModel) {
        nameLabel.text = viewModel.name
        nameTextField.text = viewModel.value
        nameTextField.isEnabled = false
    }
}
