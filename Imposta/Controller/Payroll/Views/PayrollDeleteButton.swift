//
//  PayrollDeleteButton.swift
//  Imposta
//
//  Created by Huseyn Bayramov on 26.02.21.
//  Copyright © 2021 Imposta. All rights reserved.
//

import UIKit.UIButton

@IBDesignable
class PayrollDeleteButton: UIButton {
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? .sunsetOrange : .white
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 10
        layer.masksToBounds = true
        layer.borderColor = UIColor.sunsetOrange.cgColor
        layer.borderWidth = 1
        backgroundColor = .clear
        
        setTitleColor(.white, for: .highlighted)
        setTitleColor(.sunsetOrange, for: .normal)
    }
}
