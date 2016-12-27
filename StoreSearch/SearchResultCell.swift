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
            artistNameLabel.text = String(format: "%@(%@)", searchResult.artistName, searchResult.kindForDisplay())
        }
        
        artworkImageView.image = UIImage(named: "Placeholder")
        if let smallURL = URL(string: searchResult.artworkSmallURL){
            downloadTask = artworkImageView.loadImage(url: smallURL)
        }
    }

}
