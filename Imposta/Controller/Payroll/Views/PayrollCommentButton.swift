//
//  PayrollCommentButton.swift
//  Imposta
//
//  Created by Huseyn Bayramov on 26.02.21.
//  Copyright © 2021 Imposta. All rights reserved.
//

import UIKit.UIButton

@IBDesignable
class PayrollCommentButton: UIButton {
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? .white : .mainColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 10
        layer.masksToBounds = true
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
        backgroundColor = .clear
        
        setTitleColor(.mainColor, for: .highlighted)
        setTitleColor(.white, for: .normal)
    }
}

