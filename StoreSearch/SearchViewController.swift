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
    var isLoading: Bool = false
   
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
        cellNib = UINib(nibName: tableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: tableViewCellIdentifiers.loadingCell)
        
        //make the keyboard available in the first appearence
        searchBar.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    struct tableViewCellIdentifiers{
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }
    
    func iTunesURL(_ searchText: String)-> URL{
        let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200", escapedSearchText)
        let url = URL(string: urlString)
        return url!
    }
    
    

    func parseJson(json data: Data)-> [String: Any]?{
        
        do{
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        }catch{
            print("Json Error \(error)")
            return nil
        }
    }
    
    func showNetworkError(){
        let alert = UIAlertController(title: "Whoops...", message: "There was an error reading from the iTunes Store. Please try again", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func parseDictionary(dictionary: [String : Any])-> [SearchResult]{
    
        guard let array = dictionary["results"] as? [Any] else{
            print("Expected 'results' array")
            return []
        }
        
        var searchResults: [SearchResult] = []
        
        for resultDictionary in array{
           
            if let resultDictionary = resultDictionary as? [String : Any]{
                var searchResult: SearchResult?
                if let wraperType = resultDictionary["wrapperType"] as? String{
                    switch wraperType{
                        case "track":
                            searchResult = parseTrack(track: resultDictionary)
                        case "audiobook":
                            searchResult = parseAudiobook(audiobook: resultDictionary)
                        case "software":
                            searchResult = parseSoftware(audioboo: resultDictionary)
                        default:
                            break
                    }
                }else if let kind = resultDictionary["kind"] as? String, kind == "ebook"{
                     searchResult = parseEbook(ebook: resultDictionary)
                }
                if let result = searchResult{
                    searchResults.append(result)
                }
            }
        }
        return searchResults
    }
    
    func parseTrack(track dictionary:[String:Any])-> SearchResult{
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["trackPrice"] as? Double{
            searchResult.price = price
        }
        
        if let genre = dictionary["primaryGenreName"] as? String{
            searchResult.genere = genre
        }
        
        return searchResult
    }
   
    func parseAudiobook(audiobook dictionary:[String:Any])-> SearchResult{
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["collectionName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["collectionViewUrl"] as! String
        searchResult.kind = "audiobook"
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["collectionPrice"] as? Double{
            searchResult.price = price
        }
        
        if let genre = dictionary["primaryGenreName"] as? String{
            searchResult.genere = genre
        }
        
        return searchResult
    }
    
    func parseSoftware(audioboo dictionary:[String:Any])-> SearchResult{
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["price"] as? Double{
            searchResult.price = price
        }
        
        if let genre = dictionary["primaryGenreName"] as? String{
            searchResult.genere = genre
        }
        
        return searchResult
    }
    
    func parseEbook(ebook dictionary:[String:Any])-> SearchResult{
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["price"] as? Double{
            searchResult.price = price
        }
        
        if let genres: Any = dictionary["genres"] as? String{
            searchResult.genere = (genres as! [String]).joined(separator: ", ")
        }
        
        return searchResult
    }
}

//MARK: UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if !searchBar.text!.isEmpty{
            searchBar.resignFirstResponder()
            
            isLoading = true
            tableView.reloadData()
            
            searchResults = []
            hasSearched = true
            
           
           
            let url = self.iTunesURL(searchBar.text!)
            let session = URLSession.shared
            let dataTask = session.dataTask(with: url, completionHandler: { (data, response, error) in
                
                
                if let error = error{
                    print("error \(error)")
                }else if let response = response as? HTTPURLResponse, 200 <= response.statusCode && response.statusCode <= 299{
                    
                    if let data = data, let jsonDictionary = self.parseJson(json: data){
                        self.searchResults = self.parseDictionary(dictionary: jsonDictionary)
                        self.searchResults.sort(by: <)
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.tableView.reloadData()
                        }
                        return
                    }
                    
                }
                
                DispatchQueue.main.async {
                    self.hasSearched = false
                    self.isLoading = false
                    self.tableView.reloadData()
                    self.showNetworkError()
                }
                print("failure \(response)")
                
            })
            
            dataTask.resume()
        }
    }
    
    
    
    //close the white gap from the search bar to the
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension SearchViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isLoading{
            return 1
        }else{
            let a: Int = hasSearched ? max(searchResults.count,1) : 0
            return a
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isLoading{
            let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifiers.loadingCell, for: indexPath)
            let spiner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spiner.startAnimating()
            return cell
        }
        
        if searchResults.count == 0{
            return tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifiers.nothingFoundCell, for: indexPath)
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifiers.searchResultCell, for:indexPath) as! SearchResultCell
            let searchResult = searchResults[indexPath.row]
            cell.nameLabel.text = searchResult.name
            
            if searchResult.artistName.isEmpty{
                searchResult.artistName = "Unkown"
            }else{
                cell.artistNameLabel.text = String(format: "%@ (%@)", searchResult.artistName, kindForDisplay(searchResult.kind))
            }
        
            return cell
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 || isLoading{
            return nil
        }else{
            return indexPath
        }
    }
    
    func kindForDisplay(_ kind: String) -> String{
        switch kind {
        case "album": return "Album"
        case "audiobook": return "Audio Book"
        case "book": return "Book"
        case "ebook": return "E-Book"
        case "feature-movie": return "Movie"
        case "music-video": return "Music Video"
        case "podcast": return "Podcast"
        case "software": return "App"
        case "song": return "Song"
        case "tv-episode": return "TV Episode"
        default: return kind
        }
    }

}

extension SearchViewController: UITableViewDelegate{
    
}
