//
//  Search.swift
//  StoreSearch
//
//  Created by Carlos De la mora on 12/29/16.
//  Copyright © 2016 carlosdelamora. All rights reserved.
//

import Foundation

class Search {
    
    var searchResults = [SearchResult]()
    var hasSearched = false
    var isLoading = false
    
    typealias  SearchComplete = (Bool) -> Void
    
    private var dataTask: URLSessionDataTask? = nil
    
    func performSearch (for text: String, category: Int, completion: @escaping SearchComplete ){
        
        if !text.isEmpty{
            
            
            dataTask?.cancel()
            isLoading = true
            searchResults = []
            hasSearched = true
            
            
            
            let url = self.iTunesURL(text, category: category)
            let session = URLSession.shared
            dataTask = session.dataTask(with: url) { (data, response, error) in
                
                var success = false
                
                //if there is an error and the error has the code -999 the task was cancelled else continue
                if let error = error as? NSError, error.code == -999 {
                    return
                }else if let response = response as? HTTPURLResponse, 200 <= response.statusCode && response.statusCode <= 299{
                    
                    if let data = data, let jsonDictionary = self.parseJson(json: data){
                        self.searchResults = self.parseDictionary(dictionary: jsonDictionary)
                        self.searchResults.sort(by: <)
                        
                        print("Success")
                        self.isLoading = false
                        success = true
                    }
                    
                    if !success {
                        self.hasSearched = false
                        self.isLoading = false
                    }
                    
                    DispatchQueue.main.async {
                        completion(success)
                    }
                }
                
            }
            dataTask?.resume()
        }
    }
    
    
    
    private func iTunesURL(_ searchText: String, category: Int)-> URL{
        
        let entityName: String
        switch category {
        case 1: entityName = "musicTrack"
        case 2: entityName = "software"
        case 3: entityName = "ebook"
        default: entityName = ""
        }
        
        
        let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200&entity=%@", escapedSearchText, entityName)
        let url = URL(string: urlString)
        return url!
    }
    
    
    
    private func parseJson(json data: Data)-> [String: Any]?{
        
        do{
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        }catch{
            print("Json Error \(error)")
            return nil
        }
    }
    
        
    private func parseDictionary(dictionary: [String : Any])-> [SearchResult]{
        
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
    
    private func parseTrack(track dictionary:[String:Any])-> SearchResult{
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
            searchResult.genre = genre
        }
        
        return searchResult
    }
    
    private func parseAudiobook(audiobook dictionary:[String:Any])-> SearchResult{
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
            searchResult.genre = genre
        }
        
        return searchResult
    }
    
    private func parseSoftware(audioboo dictionary:[String:Any])-> SearchResult{
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
            searchResult.genre = genre
        }
        
        return searchResult
    }
    
    private func parseEbook(ebook dictionary:[String:Any])-> SearchResult{
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
        
        if let genres: Any = dictionary["genres"] as? [String]{
            searchResult.genre = (genres as! [String]).joined(separator: ", ")
        }
        
        return searchResult
    }
    
    
}
