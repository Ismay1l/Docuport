//
//  LeftMenuDismissAnimationController.swift
//  Imposta
//
//  Created by Shamkhal Guliyev on 02.09.2019.
//  Copyright © 2018 Imposta. All rights reserved.
//

import UIKit

class LeftMenuDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    let destinationFrame: CGRect
    var duration = 0.3
    
    init(destinationFrame: CGRect) {
        self.destinationFrame = destinationFrame
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewController(forKey: .from), let toVC = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        fromVC.view.frame = destinationFrame
        
        let containerView = transitionContext.containerView
        containerView.addSubview(fromVC.view)
        
        //let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, animations: {
            fromVC.view.frame = CGRect(x: 0-fromVC.view.frame.size.height, y: 0, width: fromVC.view.frame.size.height, height: toVC.view.frame.size.height)
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
