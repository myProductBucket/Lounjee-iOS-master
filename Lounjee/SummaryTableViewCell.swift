//
//  EditTableViewCell.swift
//  Lounjee
//
//  Created by Junior Boaventura on 21.03.16.
//  Copyright © 2016 Junior. All rights reserved.
//

import UIKit

class SummaryTableViewCell: UITableViewCell {

    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var editWidth: NSLayoutConstraint!
    var editable:Bool = true {
        didSet {
            if self.editable == false {
                self.editButton.hidden = true
                self.editWidth.constant = 0.0
            }
            else {
                self.editButton.hidden = false
                self.editWidth.constant = 35.0
            }
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    
}
