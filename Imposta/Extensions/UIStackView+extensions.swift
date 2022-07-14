//
//  UIStackView+extensions.swift
//  Imposta
//
//  Created by Huseyn Bayramov on 02.03.21.
//  Copyright © 2021 Imposta. All rights reserved.
//

import UIKit.UIStackView

extension UIStackView {
    func addBackground(color: UIColor) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = .disablePayroll
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }
}
