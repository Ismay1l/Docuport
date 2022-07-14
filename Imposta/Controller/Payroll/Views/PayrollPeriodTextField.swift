//
//  PayrollPeriodTextField.swift
//  Imposta
//
//  Created by Huseyn Bayramov on 16.03.21.
//  Copyright © 2021 Imposta. All rights reserved.
//

import UIKit.UITextField

class PayrollPeriodTextField: UITextField {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.mainColor.cgColor
        layer.cornerRadius = 10
        layer.masksToBounds = true

        let arrowIcon = UIImageView(image: UIImage(named: "payroll_arrow_ic"))
        rightViewMode = .always
        rightView = arrowIcon
        
        delegate = self
    }
}

extension PayrollPeriodTextField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.width - 24, y: 16, width: 16, height: 10)
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        return .zero
    }
}
