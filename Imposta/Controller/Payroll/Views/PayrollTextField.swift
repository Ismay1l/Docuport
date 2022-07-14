//
//  PayrollTextField.swift
//  Imposta
//
//  Created by Huseyn Bayramov on 25.02.21.
//  Copyright © 2021 Imposta. All rights reserved.
//
import UIKit.UITextField

class PayrollTextField: UITextField {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.mainColor.cgColor
        layer.cornerRadius = 10
        layer.masksToBounds = true
        delegate = self
    }
}

extension PayrollTextField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text, let rangeOfText = Range(range, in: textFieldText) else { return false }
        let substringToReplace = textFieldText[rangeOfText]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 100
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.width - 24, y: 16, width: 16, height: 10)
    }
    
    func isEmptyVerifier() -> (() -> Bool?) {
        return { [weak self] in
            let count = self?.text?.count ?? 0
            return count == 0 ? true : false
        }
    }
}
