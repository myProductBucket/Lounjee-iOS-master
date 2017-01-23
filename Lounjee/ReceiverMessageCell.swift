//
//  ReceiverCell.swift
//  Lounjee
//
//  Created by Junior Boaventura on 15.03.16.
//  Copyright © 2016 Junior. All rights reserved.
//

import UIKit

class ReceiverMessageCell: UITableViewCell {
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
