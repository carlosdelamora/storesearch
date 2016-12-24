//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by Carlos De la mora on 12/21/16.
//  Copyright © 2016 carlosdelamora. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {

    var downloadTask: URLSessionDownloadTask?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 0.5)
        selectedBackgroundView = selectedView
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        downloadTask?.cancel()
        downloadTask = nil 
    }
    
    func configure(for searchResult: SearchResult){
        nameLabel.text = searchResult.name
        
        if searchResult.artistName.isEmpty{
            artistNameLabel.text = "Unkown"
        }else{
            artistNameLabel.text = String(format: "%@(%@)", searchResult.artistName, kindForDisplay(searchResult.kind))
        }
        
        artworkImageView.image = UIImage(named: "Placeholder")
        if let smallURL = URL(string: searchResult.artworkSmallURL){
            downloadTask = artworkImageView.loadImage(url: smallURL)
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
