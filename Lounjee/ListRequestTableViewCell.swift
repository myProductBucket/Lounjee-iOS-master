//
//  ListRequestTableViewCell.swift
//  Lounjee
//
//  Created by Arnaud AUBRY on 17/05/2016.
//  Copyright © 2016 Junior. All rights reserved.
//

import UIKit

class ListRequestTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: ProfilePicture!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
