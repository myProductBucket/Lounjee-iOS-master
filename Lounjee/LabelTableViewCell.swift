//
//  LabelTableViewCell.swift
//  Lounjee
//
//  Created by Junior Boaventura on 21.03.16.
//  Copyright © 2016 Junior. All rights reserved.
//

import UIKit

class LabelTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var editWidth: NSLayoutConstraint!
    var editable: Bool = true {
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

    var cellColor: UIColor!
    var cellUnmatchedColor: UIColor!
    
    private var data = [String]()
    private var currentUser_data = [String]()
    
    private var matchedArray = [Int]()
    
    func configureWithData(data: [String], currentUser_data: [String]) {
        
        matchedArray.removeAll()
        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 10.0
            layout.minimumInteritemSpacing = 10.0
            layout.sectionInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)
        }

        self.data = data
        self.currentUser_data = currentUser_data
        
        var matched_flag = false
        
        for data_element in data{
            
            matched_flag = false
            for userdata_element in currentUser_data{
                if data_element.compare(userdata_element) == NSComparisonResult.OrderedSame{
                    matched_flag = true
                    matchedArray.append(1)
                }
            }
            
            if matched_flag == false{
                matchedArray.append(0)
            }
        }
        
        var index: Int = 0
        for statusItem in matchedArray {
            if statusItem == 1 {
                matchedArray.removeAtIndex(index)
                matchedArray.insert(1, atIndex: 0)
                let datum = self.data[index]
                self.data.removeAtIndex(index)
                self.data.insert(datum, atIndex: 0)
            }
            
            index += 1
        }
        
        self.collectionView.reloadData()
        self.collectionViewHeight.constant = self.collectionView?.collectionViewLayout.collectionViewContentSize().height ?? 0.0
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.selectionStyle = .None
        self.collectionView.userInteractionEnabled = false
        self.collectionView.scrollEnabled = true
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.backgroundColor = UIColor.clearColor()
    }
}

extension LabelTableViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let label = UILabel()

        label.font = UIFont(name: "MyriadPro-SemiBold", size: 12)
        label.text = self.data[indexPath.row].uppercaseString
        label.sizeToFit()
        return CGSizeMake(label.bounds.width + 10.0, 22.0)
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionViewCell", forIndexPath: indexPath) as! InterestCollectionViewCell

        if matchedArray[indexPath.row] == 1{
            cell.backgroundColor = self.cellColor
            cell.interestLabel.textColor = UIColor.whiteColor()
        }
        else{
            cell.backgroundColor = UIColor.clearColor()
            cell.interestLabel.textColor = self.cellColor
        }
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = self.cellColor.CGColor
        
        //cell.backgroundColor = self.cellColor
        cell.interestLabel.textAlignment = .Center
        cell.interestLabel.text = self.data[indexPath.row].uppercaseString
        return cell
    }
}
