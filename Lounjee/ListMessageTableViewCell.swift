//
//  MessageTableViewCell.swift
//  Lounjee
//
//  Created by Junior Boaventura on 11.03.16.
//  Copyright © 2016 Junior. All rights reserved.
//

import UIKit

class ListMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var profileImgView: ProfilePicture!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var meTextWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
