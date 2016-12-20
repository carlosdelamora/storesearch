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
    var searchResults = [String]()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

//MARK: UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchResult = SearchResult()
        for i in 0...2{
            searchResults.append(String(format: "Fake Results for %d, '%@'", i, searchBar.text!))
        }
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
    
    //close the white gap from the search bar to the status bar
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension SearchViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SerchResultCell"
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil{
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        
        cell.textLabel?.text = searchResults[indexPath.row]
        return cell
    }
}

extension SearchViewController: UITableViewDelegate{
    
}
