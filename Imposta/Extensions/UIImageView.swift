//
//  UIImageView.swift
//  Imposta
//
//  Created by Rovshen Shirinzade on 8/19/20.
//  Copyright © 2020 Rovshen Shirinzade. All rights reserved.
//

import UIKit
import SDWebImage

extension UIImageView {
    
    func sd_setImageRefreshCached(imageURL: String?, placeholderImage: UIImage?) {
//        self.sd_setShowActivityIndicatorView(true)
//        self.sd_setIndicatorStyle(.gray)
        self.sd_setImage(with: URL(string: imageURL!), placeholderImage: placeholderImage, options: SDWebImageOptions.refreshCached)
    }
    
    func roundCorners(_ corners:UIRectCorner, _ radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    //Responsiblity: to holds the List of Activity Indicator for ImageView
  
}

@IBDesignable extension UIImageView {
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}
