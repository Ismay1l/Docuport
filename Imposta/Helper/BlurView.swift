//
//  BlurView.swift
//  Imposta
//
//  Created by Huseyn Bayramov on 24.02.21.
//  Copyright © 2021 Imposta. All rights reserved.
//

import UIKit

class BlurView: UIView {
    var blurEffect: UIBlurEffect?
    var blurEffectView: UIVisualEffectView?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        blurEffectView?.frame = self.bounds
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)

        blurEffectView?.frame = self.bounds
        blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.insertSubview(blurEffectView!, at: 0)
    }
}
