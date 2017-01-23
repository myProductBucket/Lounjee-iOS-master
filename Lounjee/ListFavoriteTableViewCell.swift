//
//  ListFavoriteTableViewCell.swift
//  Lounjee
//
//  Created by Daniel Drescher on 01/09/16.
//  Copyright © 2016 Junior. All rights reserved.
//

import UIKit

class ListFavoriteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImgView: ProfilePicture!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.nameLabel.text = ""
        self.cityLabel.text = ""
        self.countryLabel.text = ""
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
