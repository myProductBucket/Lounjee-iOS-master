//
//  FavoritesHorizontalScrollCell.swift
//  Lounjee
//
//  Created by Daniel Drescher on 02/09/16.
//  Copyright © 2016 Junior. All rights reserved.
//

import UIKit

class FavoritesHorizontalScrollCell: UITableViewCell {
    
    @IBOutlet weak var favoriteScrollView: ASHorizontalScrollView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.favoriteScrollView.showsHorizontalScrollIndicator = false
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
