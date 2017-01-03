//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by Carlos De la mora on 12/24/16.
//  Copyright © 2016 carlosdelamora. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var searchResult:SearchResult!
    var downloadTask: URLSessionDownloadTask?
    var dismissAnimationStyle = AnimationStyle.fade
    
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var artworkImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    deinit {
        print("deinit \(self)")
        downloadTask?.cancel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        view.tintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
        popUpView.layer.cornerRadius = 10
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        
        if searchResult != nil{
            updateUI()
        }
    }


    @IBAction func close(){
        
        dismissAnimationStyle = .slide
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openInStore(){
        if let url = URL(string: searchResult.storeURL){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    enum AnimationStyle {
        
        case slide
        case fade
    }
    
    func updateUI(){
        
        nameLabel.text = searchResult.name
        if searchResult.artistName.isEmpty{
            artistNameLabel.text = NSLocalizedString("Unknown", comment: "Localized kind: Unknown DetailViewController")
        }else{
            artistNameLabel.text = searchResult.artistName
        }
        kindLabel.text = searchResult.kindForDisplay()
        genreLabel.text = searchResult.genre
        
        //set the format for the price
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = searchResult.currency
        
        let priceText: String
        if searchResult.price == 0{
            priceText = NSLocalizedString("Free", comment: "Localized kind: Free")
        }else if let text = formatter.string(from: searchResult.price as NSNumber){
            priceText = text
        }else{
            priceText = ""
        }
        
        priceButton.setTitle(priceText, for: .normal)
        
        if let largeUrl = URL(string: searchResult.artworkLargeURL){
            downloadTask = artworkImage.loadImage(url: largeUrl)
        }
    }
    
}

extension DetailViewController: UIViewControllerTransitioningDelegate{
    //set the presentation controller to be the dimmining Prsentation Controller, it sets the presenting view should not be dismissed
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return BounceAnimationController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        switch dismissAnimationStyle {
        case .slide:
            return SlideOutAnimationController()
        case .fade:
            return FadeOutAnimationController()
        }
    }
    
    
}

extension DetailViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return (touch.view === self.view)
    }
}
