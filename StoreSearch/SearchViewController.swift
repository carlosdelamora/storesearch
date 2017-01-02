//
//  ViewController.swift
//  StoreSearch
//
//  Created by Carlos De la mora on 12/20/16.
//  Copyright © 2016 carlosdelamora. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    //MARK: Properties
    let search = Search()
    var landscapeViewController: LandscapeViewController?
    
    //MARK: IBOulet
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = 80
        
        //upload the nib for the cell and register it to the table view
        var cellNib = UINib(nibName: tableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: tableViewCellIdentifiers.searchResultCell)
        cellNib = UINib(nibName: tableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: tableViewCellIdentifiers.nothingFoundCell)
        cellNib = UINib(nibName: tableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: tableViewCellIdentifiers.loadingCell)
        
        //make the keyboard available in the first appearence
        searchBar.becomeFirstResponder()
        
        NotificationCenter.default.addObserver(self, selector: #selector(sizeChanged), name:NSNotification.Name.UIContentSizeCategoryDidChange , object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
        print("no more notifications")
    }
    
    
    //MARK: actions
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        performSearch()
        print("segment changed \(sender.selectedSegmentIndex)")
    }
    
    struct tableViewCellIdentifiers{
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }
    
    
    func sizeChanged(){
        tableView.reloadData()
        print("the size changed")
    }
    
    func showNetworkError(){
        let alert = UIAlertController(title: "Whoops...", message: "There was an error reading from the iTunes Store. Please try again", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail"{
            
            if case .results(let list) = search.state {
                let detailViewController = segue.destination as! DetailViewController
                let indexPath = sender as! IndexPath
                let searchResult = list[indexPath.row]
                detailViewController.searchResult = searchResult
 
            }
        }
    }
}

//MARK: UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate{
    func performSearch() {
        
        if let category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex){
            
            search.performSearch(for: searchBar.text!, category: category){
                
                success in
                //change false for success
                if !success {
                    self.showNetworkError()
                }else{
                    self.tableView.reloadData()
                    self.landscapeViewController?.hideSpinner()
                }
            }
            
            //this reloadData is to show the downloading cell
            tableView.reloadData()
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    
    //close the white gap from the search bar to the
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension SearchViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch search.state{
        case .notSearchedYet:
            return 0
        case .loading:
            return 1
        case .noResults:
            return 1
        case .results(let list):
            return list.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch search.state{
        case .notSearchedYet:
            let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifiers.loadingCell, for: indexPath)
            let spiner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spiner.startAnimating()
            return cell
            
        case .loading:
            let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifiers.loadingCell, for: indexPath)
            let spiner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spiner.startAnimating()
            return cell
        
        case .noResults:
             return tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifiers.nothingFoundCell, for: indexPath)
            
        case .results( let list):
            let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifiers.searchResultCell, for:indexPath) as! SearchResultCell
            let searchResult = list[indexPath.row]
            cell.configure(for: searchResult)
            return cell
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ShowDetail", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch search.state {
        case .notSearchedYet,.noResults,.loading:
            return nil
            
        case .results:
            return indexPath
        }
    }
    
}

extension SearchViewController: UITableViewDelegate{
    
}

//set evrything with landscapeViewController
extension SearchViewController{
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        switch newCollection.verticalSizeClass{
        case .compact:
            showLandscape(with:coordinator)
        case .regular, .unspecified:
            hideLanscape(with: coordinator)
        }
    }
    
    func showLandscape(with coordinator: UIViewControllerTransitionCoordinator){
        
        guard landscapeViewController == nil else {
            return
        }
        
        landscapeViewController = storyboard!.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController
        
        if let controller = landscapeViewController{
            
            controller.search = search
            controller.view.frame = view.bounds
            controller.view.alpha = 0
            
            //we need to add the controller
            view.addSubview(controller.view) //first add the view
            addChildViewController(controller) // tell the searchViewController the screen is managed by the child view
            
            coordinator.animate(alongsideTransition: { _ in
                controller.view.alpha = 1
                //gets rid of the keyboard if is present when it goes into landscape
                self.searchBar.resignFirstResponder()
                //removes the detailview controller if is present
                if self.presentedViewController != nil {
                    self.dismiss(animated: true, completion: nil)
                }
            }, completion:{ _ in
                controller.didMove(toParentViewController: self)//didMove tells the newView controller it has a parent
                
            })
        }
    }
    
    func hideLanscape(with coordinator: UIViewControllerTransitionCoordinator){
        
        if let controller = landscapeViewController{
            
            controller.willMove(toParentViewController: nil)
            
            coordinator.animate(alongsideTransition: { _ in
                controller.view.alpha = 0
            }, completion:{ _ in
                
                controller.view.removeFromSuperview()
                controller.removeFromParentViewController()
                self.landscapeViewController = nil
                
            })
        }
    }
    
    
}

