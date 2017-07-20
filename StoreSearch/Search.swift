//
//  Search.swift
//  StoreSearch
//
//  Created by Carlos De la mora on 12/29/16.
//  Copyright © 2016 carlosdelamora. All rights reserved.
//
import UIKit
import Foundation

class Search {
    
    private var dataTask: URLSessionDataTask? = nil
    private(set) var state: State = .notSearchedYet
    typealias  SearchComplete = (Bool) -> Void
    
    enum State{
        case notSearchedYet //this is the state in case of an error
        case loading
        case noResults
        case results([SearchResult])
    }
    
    
    
    enum Category: Int{
        case all = 0
        case music = 1
        case software = 2
        case ebooks = 3
        
        var entityName: String {
            switch self {
            case .all: return ""
            case .music: return "musicTrack"
            case .software: return "software"
            case .ebooks: return "ebook"
            }
        }
    }
    
    
    func performSearch (for text: String, category: Category, completion: @escaping SearchComplete ){
        
        if !text.isEmpty{
            
            
            dataTask?.cancel()
            state = .loading
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            
            let url = self.iTunesURL(text, category: category)
            let session = URLSession.shared
            dataTask = session.dataTask(with: url) { (data, response, error) in
               
                self.state = .notSearchedYet
                var success = false
                
                //if there is an error and the error has the code -999 the task was cancelled else continue
                if let error = error as? NSError, error.code == -999 {
                    return
                }else if let response = response as? HTTPURLResponse, 200 <= response.statusCode && response.statusCode <= 299{
                    
                    if let data = data, let jsonDictionary = self.parseJson(json: data){
                        
                        var searchResults = self.parseDictionary(dictionary: jsonDictionary)
                        if searchResults.isEmpty {
                            
                            self.state = .noResults
                        }else{
                            searchResults.sort(by: <)
                            
                            self.state = .results(searchResults)
                        }
                        success = true
                    }
                }
                
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false 
                    completion(success)
                }
                
            }
            dataTask?.resume()
        }
    }
    
    
    
    private func iTunesURL(_ searchText: String, category: Category)-> URL{
        
        let entityName = category.entityName
        let locale = Locale.autoupdatingCurrent
        let language = locale.identifier
        let countryCode = locale.regionCode ?? "en_US"
        
        let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200&entity=%@&lang=%@&country=%@", escapedSearchText, entityName, language, countryCode)
        let url = URL(string: urlString)
        print(url!)
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
