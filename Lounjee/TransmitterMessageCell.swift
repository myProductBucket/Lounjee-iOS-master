//
//  TransmitterMessageCell.swift
//  Lounjee
//
//  Created by Junior Boaventura on 14.03.16.
//  Copyright © 2016 Junior. All rights reserved.
//

import UIKit

protocol TransmitterMessageCellDelegate {
    func onClickProfileImage()
}

class TransmitterMessageCell: UITableViewCell {
    var delegate: TransmitterMessageCellDelegate?

    @IBOutlet weak var profilePicture: ProfilePicture!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onTouchProfileImage(){
        delegate?.onClickProfileImage()
    }

}
