//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by Carlos De la mora on 12/27/16.
//  Copyright © 2016 carlosdelamora. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {

    
    var search: Search!
    private var firstTime = true
    private var downloadTasks = [URLSessionDownloadTask]()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageControl.numberOfPages = 0
        
        removeContraints(aView: view)
        removeContraints(aView: pageControl)
        removeContraints(aView: scrollView)
        scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        scrollView.frame = view.bounds
        pageControl.frame = CGRect(x: 0, y: view.frame.size.height - pageControl.frame.size.height, width: view.frame.size.width, height: pageControl.frame.size.height)
        
        if firstTime{
            firstTime = false
            switch search.state{
            case .notSearchedYet:
                break
            case .loading:
                break
            case .noResults:
                break
            case .results(let list):
                titleButtons(list)
            }
        }
    }
    
    @IBAction func pageChanged(_ sender: UIPageControl){
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
            self.scrollView.contentOffset = CGPoint(x: self.scrollView.bounds.size.width * CGFloat(sender.currentPage), y: 0)
        }, completion: nil)
        
        
    }
    
    private func titleButtons(_ searchResults: [SearchResult]){
        
        var columnsPerPage = 5
        var rowsPerPage = 3
        var itemWidth: CGFloat = 96
        var itemHeight: CGFloat = 88
        var marginX: CGFloat = 0
        var marginY: CGFloat = 20
        
        let scrollViewWidth = scrollView.bounds.size.width
        
        switch scrollViewWidth{
        
        case 568:
            columnsPerPage = 6
            itemWidth = 94
            marginX = 2
        case 667:
            columnsPerPage = 7
            itemWidth = 95
            itemHeight = 98
            marginX = 1
            marginY = 29
            
        case 736:
            columnsPerPage = 8
            rowsPerPage = 4
            itemWidth = 92
            
        default:
            break
        }
        
        let buttonWidth: CGFloat = 82
        let buttonHeight: CGFloat = 82
        let paddingHorizontally = (itemWidth - buttonWidth)/2
        let paddingVertically = (itemHeight - buttonHeight)/2
        
        var row = 0
        var column = 0
        var x = marginX
        
        for ( _ , searchResult) in searchResults.enumerated(){
            let button = UIButton(type: .custom)
            downloadImage(for: searchResult, andPlaceOn: button)
            button.frame = CGRect(x: x + paddingHorizontally, y: marginY + CGFloat(row)*itemHeight + paddingVertically, width: buttonWidth, height: buttonHeight)
            
            scrollView.addSubview(button)
            
            row += 1
            
            if row == rowsPerPage{
                row = 0; x += itemWidth; column += 1
                
                if column == columnsPerPage {
                    column = 0; x += marginX*2
                }
            }
        }
        
        let buttonsPerPage = columnsPerPage*rowsPerPage
        let numPages = 1 + (searchResults.count - 1)/buttonsPerPage
        scrollView.contentSize = CGSize( width: CGFloat(numPages)*scrollViewWidth, height: scrollView.bounds.size.height)
        print("number of pages \(numPages)")
        
        pageControl.numberOfPages = numPages
        pageControl.currentPage = 0
    }
    
    private func downloadImage( for searchResult: SearchResult, andPlaceOn button: UIButton){
        
        if let url = URL(string: searchResult.artworkSmallURL){
            let downloadTask = URLSession.shared.downloadTask(with: url){
                [ weak button] url, response, error in
                if error == nil, let url = url, let data = try? Data(contentsOf: url), let image = UIImage(data: data){
                    DispatchQueue.main.async {
                        if let button = button{
                            button.setImage(image, for: .normal)
                        }
                    }
                }
            }
            downloadTask.resume()
            downloadTasks.append(downloadTask)
        }
    }
    
    func removeContraints(aView: UIView){
        aView.removeConstraints(aView.constraints)
        aView.translatesAutoresizingMaskIntoConstraints = true
    }
    
    
    deinit{
        print("deinit \(self)")
        for task in downloadTasks{
            task.cancel()
        }
    }
    
}


extension LandscapeViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.size.width
        let currentPage = Int((scrollView.contentOffset.x + width/2)/width)
        pageControl.currentPage = currentPage
    }
}

