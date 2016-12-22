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
    var searchResults = [SearchResult]()
    var hasSearched:Bool = false
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = 80
        
        //upload the nib for the cell and register it to the table view
        var cellNib = UINib(nibName: tableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: tableViewCellIdentifiers.searchResultCell)
        cellNib = UINib(nibName: tableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: tableViewCellIdentifiers.nothingFoundCell)
        
        //make the keyboard available in the first appearence
        searchBar.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    struct tableViewCellIdentifiers{
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
    }

}

//MARK: UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchResults = []
        hasSearched = true
        if searchBar.text! != "Justin biber"{
            for i in 0...2{
                let searchResult = SearchResult()
                searchResult.name = String(format: "Fake Results %d for", i)
                searchResult.artistName = searchBar.text!
                searchResults.append(searchResult)
            }
        }
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
    
    //close the white gap from the search bar to the
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension SearchViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let a: Int = hasSearched ? max(searchResults.count,1) : 0
        return a
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if searchResults.count == 0{
            return tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifiers.nothingFoundCell, for: indexPath)
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifiers.searchResultCell, for:indexPath) as! SearchResultCell
            let searchResult = searchResults[indexPath.row]
            cell.nameLabel.text = searchResult.name
            cell.artistNameLabel.text = searchResult.artistName
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 {
            return nil
        }else{
            return indexPath
        }
    }
    
    
    
    
}

extension SearchViewController: UITableViewDelegate{
    
}
