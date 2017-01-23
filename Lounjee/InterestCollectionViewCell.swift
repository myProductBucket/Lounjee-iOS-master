//
//  InterestCollectionViewCell.swift
//  Lounjee
//
//  Created by Junior Boaventura on 11.03.16.
//  Copyright © 2016 Junior. All rights reserved.
//

import UIKit

class InterestCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var interestLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 4.0
        self.clipsToBounds = true
    }
}
