//
//  LeftMenuPresentAnimationController.swift
//  Imposta
//
//  Created by Shamkhal Guliyev on 02.09.2019.
//  Copyright © 2018 Imposta. All rights reserved.
//

import UIKit

class LeftMenuPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    let originFrame: CGRect
    var duration = 0.3
    
    init(originFrame: CGRect) {
        self.originFrame = originFrame
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewController(forKey: .from), let toVC = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        toVC.view.frame = originFrame
        
        let containerView = transitionContext.containerView
        containerView.addSubview(toVC.view)
        
        //let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, animations: {
            toVC.view.frame = CGRect(x: 0, y: 0, width: toVC.view.frame.size.height, height: fromVC.view.frame.size.height)
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
