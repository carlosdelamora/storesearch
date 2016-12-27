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
    override var shouldRemovePresentersView: Bool {
        return false
    }
    
    lazy var dimingView = GradientView(frame: CGRect.zero)
    
    override func presentationTransitionWillBegin() {
        dimingView.frame = containerView!.bounds
        containerView!.insertSubview(dimingView, at: 0)
    }
}
