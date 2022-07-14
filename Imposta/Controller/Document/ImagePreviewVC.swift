
//
//  ImagePreviewVC.swift
//  Imposta
//
//  Created by Ulxan Emiraslanov on 9/30/20.
//  Copyright © 2020 Imposta. All rights reserved.
//

import UIKit
import Kingfisher

class ImagePreviewVC: UIViewController {

    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shareBtn: UIBarButtonItem! {
        didSet {
            shareBtn.isEnabled = false
        }
    }
    
    var imagePath: String?
    var navTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navBar.title = navTitle
        scrollView.maximumZoomScale = 4
        scrollView.minimumZoomScale = 1
        
        
      
        scrollView.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        imageView.kf.indicatorType = .activity
        let modifier = AnyModifier { request in
            var r = request
            // replace "Access-Token" with the field name you need, it's just an example
            r.setValue("Bearer \(UserDefaultsHelper.shared.getToken())", forHTTPHeaderField: "Authorization")
            return r
        }
        
        let url = URL(string: imagePath ?? "")
        
        imageView.kf.setImage(with: url, options: [.requestModifier(modifier)]) { (image, error, type, url) in
            if error == nil && image != nil {
                self.shareBtn.isEnabled = true
            }
        }
    }
    
    @IBAction func shareBtnTapped() {
        let shareVC = UIActivityViewController(activityItems: [imageView.image, navTitle], applicationActivities: nil)
        self.present(shareVC, animated: true, completion: nil)
    }
    
    @IBAction func doneTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ImagePreviewVC: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale > 1 {
            if let image = imageView.image {
                let ratioW = imageView.frame.width / image.size.width
                let ratioH = imageView.frame.height / image.size.height
                
                let ratio = ratioW < ratioH ? ratioW : ratioH
                let newWidth = image.size.width * ratio
                let newHeight = image.size.height * ratio
                let conditionLeft = newWidth*scrollView.zoomScale > imageView.frame.width
                let left = 0.5 * (conditionLeft ? newWidth - imageView.frame.width : (scrollView.frame.width - scrollView.contentSize.width))
                let conditioTop = newHeight*scrollView.zoomScale > imageView.frame.height
                
                let top = 0.5 * (conditioTop ? newHeight - imageView.frame.height : (scrollView.frame.height - scrollView.contentSize.height))
                
                scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
                
            }
        } else {
            scrollView.contentInset = .zero
        }
    }
}
