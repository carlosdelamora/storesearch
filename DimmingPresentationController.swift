//
//  DimmingPresentationController.swift
//  StoreSearch
//
//  Created by Carlos De la mora on 12/25/16.
//  Copyright © 2016 carlosdelamora. All rights reserved.
//

import UIKit

// we use this class and set the should Remorve presentation to false
class DimmingPresentationController: UIPresentationController{
    
    
    lazy var dimmingView = GradientView(frame: CGRect.zero)

    
    override var shouldRemovePresentersView: Bool {
        return false
    }
    
    //the animation of the presentation of the gradient
    override func presentationTransitionWillBegin() {
        dimmingView.frame = containerView!.bounds
        containerView!.insertSubview(dimmingView, at: 0)
        
        dimmingView.alpha = 0
        if let coordinator = presentedViewController.transitionCoordinator{
            coordinator.animate(alongsideTransition:{ _ in
                self.dimmingView.alpha = 1
            }, completion: nil)
        }
    }
    
    //the animation of the dismissal of the gradient
    override func dismissalTransitionWillBegin() {
        if let coordinator = presentedViewController.transitionCoordinator{
            coordinator.animate(alongsideTransition:{ _ in
            self.dimmingView.alpha = 1}, completion: nil)
        }
    }
}
