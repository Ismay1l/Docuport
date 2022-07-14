//
//  PayrollButton.swift
//  Imposta
//
//  Created by Huseyn Bayramov on 25.02.21.
//  Copyright © 2021 Imposta. All rights reserved.
//

import UIKit.UIButton

@IBDesignable
class PayrollButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 10
        layer.masksToBounds = true
        layer.borderColor = UIColor.mainColor.cgColor
        layer.borderWidth = 1
        backgroundColor = .mainColor
    }
}
