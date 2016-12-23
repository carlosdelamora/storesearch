//
//  SearchResults.swift
//  StoreSearch
//
//  Created by Carlos De la mora on 12/20/16.
//  Copyright © 2016 carlosdelamora. All rights reserved.
//

import Foundation

class SearchResult{
   
    var name = ""
    var artistName = ""
    var artworkSmallURL = ""
    var artworkLargeURL = ""
    var storeURL = ""
    var kind = ""
    var currency = ""
    var price = 0.0
    var genere = ""
    
    
}


func < (lhs:SearchResult, rhs:SearchResult) -> Bool{
    return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
}
