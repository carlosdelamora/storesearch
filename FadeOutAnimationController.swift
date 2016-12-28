//
//  FadeOutAnimationController.swift
//  StoreSearch
//
//  Created by Carlos De la mora on 12/28/16.
//  Copyright © 2016 carlosdelamora. All rights reserved.
//

import UIKit

class FadeOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning{
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        //fromView refers to the popUp view, we use this class to dismiss the popUp view and that is why we use from
        if let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from){
            let duration = transitionDuration(using: transitionContext)
            UIView.animate(withDuration: duration, animations: {
                fromView.alpha = 0
                fromView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            }, completion: { finished in
                    transitionContext.completeTransition(finished)
            })
        }
    }
}
