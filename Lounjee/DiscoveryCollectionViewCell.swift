//
//  DiscoveryCollectionViewCell.swift
//  Lounjee
//
//  Created by Junior Boaventura on 02.03.16.
//  Copyright © 2016 Junior. All rights reserved.
//

import UIKit
import KTCenterFlowLayout
import CoreLocation

class DiscoveryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var bannerImgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var meetImageView: UIImageView!
    @IBOutlet weak var laterImageView: UIImageView!
    @IBOutlet weak var userBanner: UIImageView!
    @IBOutlet weak var iconLocation: UIImageView!
    @IBOutlet weak var profileImgView: ProfilePicture!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var summaryLabel: UILabel!
    
    @IBOutlet weak var labelCollectionView: UICollectionView!
    @IBOutlet weak var industryCollectionView: UICollectionView!
    
    @IBOutlet weak var meetView: UIView!
    @IBOutlet weak var laterView: UIView!
    //var userData:UserModel?
    
    var user_lookings = [String]()
    var user_offers = [String]()
    
    private var matchedArray_lookings = [Int]()
    private var matchedArray_offers = [Int]()
    
    var lookings = [String]() {
        didSet {
            self.labelCollectionView?.reloadData()
        }
    }
    
    var offers = [String]() {
        didSet {
            self.labelCollectionView?.reloadData()
        }
    }
    
    var industries = [String]() {
        didSet {
            self.industryCollectionView?.reloadData()
        }
    }
    
    var cellColor: UIColor!
    var cellUnmatchedColor: UIColor!
    
    private var data = [String]()
    private var currentUser_data = [String]()
    
    private var matchedLookingArray = [Int]()
    private var matchedOfferArray = [Int]()
    private var matchedIndustryArray = [Int]()
    
    func configureWithIndustryData(data: [String], currentUser_data: [String]) {
        
        matchedIndustryArray.removeAll()
        if let layout = self.industryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 0.0
            layout.minimumInteritemSpacing = 10.0
            layout.sectionInset = UIEdgeInsetsMake(0.0, 10.0, 10.0, 10.0)
        }
        
        self.data = data
        self.currentUser_data = currentUser_data
        
        var matched_flag = false
        
        for data_element in data{
            
            matched_flag = false
            for userdata_element in currentUser_data{
                if data_element.compare(userdata_element) == NSComparisonResult.OrderedSame{
                    matched_flag = true
                    matchedIndustryArray.append(1)
                }
            }
            
            if matched_flag == false{
                matchedIndustryArray.append(0)
            }
        }
        // Resort to display the matched item first
        var index: Int = 0
        for statusItem in matchedIndustryArray {
            if statusItem == 1 {
                matchedIndustryArray.removeAtIndex(index)
                matchedIndustryArray.insert(1, atIndex: 0)
                let industry = self.industries[index]
                self.industries.removeAtIndex(index)
                self.industries.insert(industry, atIndex: 0)
            }
            
            index += 1
        }
        
        self.industryCollectionView.reloadData()
        
    }
    
    func configureWithLookingData(data: [String], currentUser_data: [String]) {
        
        matchedLookingArray.removeAll()
        if let layout = self.labelCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 10.0
            layout.minimumInteritemSpacing = 10.0
            layout.sectionInset = UIEdgeInsetsMake(5.0, 10.0, 0.0, 10.0)
        }
        
        self.data = data
        self.currentUser_data = currentUser_data
        
        var matched_flag = false
        
        for data_element in data{
            
            matched_flag = false
            for userdata_element in currentUser_data{
                if data_element.compare(userdata_element) == NSComparisonResult.OrderedSame{
                    matched_flag = true
                    matchedLookingArray.append(1)
                }
            }
            
            if matched_flag == false{
                matchedLookingArray.append(0)
            }
        }
        
        // Resort to display the matched item first
//        var testMatchedArray = matchedLookingArray
//        var testLookings = self.lookings
        
        var index: Int = 0
        for statusItem in matchedLookingArray {
            if statusItem == 1 {
                matchedLookingArray.removeAtIndex(index)
                matchedLookingArray.insert(1, atIndex: 0)
                let looking = self.lookings[index]
                self.lookings.removeAtIndex(index)
                self.lookings.insert(looking, atIndex: 0)
            }
            
            index += 1
        }
        
//        testMatchedArray = matchedLookingArray
//        testLookings = self.lookings
        
        self.labelCollectionView.reloadData()
        
    }
    
    func configureWithOfferData(data: [String], currentUser_data: [String]) {
        
        matchedOfferArray.removeAll()
        if let layout = self.labelCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
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
                    matchedOfferArray.append(1)
                }
            }
            
            if matched_flag == false{
                matchedOfferArray.append(0)
            }
        }
        
        // Resort to display the matched item first
        var index: Int = 0
        for statusItem in matchedOfferArray {
            if statusItem == 1 {
                matchedOfferArray.removeAtIndex(index)
                matchedOfferArray.insert(1, atIndex: 0)
                let looking = self.offers[index]
                self.offers.removeAtIndex(index)
                self.offers.insert(looking, atIndex: 0)
            }
            
            index += 1
        }
        
        self.labelCollectionView.reloadData()
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        if let layout = self.labelCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 8.0
            layout.minimumInteritemSpacing = 8.0
            layout.sectionInset = UIEdgeInsetsMake(0.0, 10.0, 10.0, 10.0)
        }
        
        let layout = KTCenterFlowLayout()
        layout.minimumInteritemSpacing = 5.0
        layout.minimumLineSpacing = 10.0
        layout.sectionInset = UIEdgeInsetsMake(0.0, 10.0, 10.0, 10.0)
        
        self.meetImageView.layer.cornerRadius = 5
        self.laterImageView.layer.cornerRadius = 5
        
        self.meetImageView.clipsToBounds = true
        self.laterImageView.clipsToBounds = true
        
        self.industryCollectionView.collectionViewLayout = layout        
    }
}

extension DiscoveryCollectionViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let label = UILabel()
        label.font = UIFont(name: "MyriadPro-Bold", size: 12)

        if collectionView == industryCollectionView{
            label.text = self.industries[indexPath.row].uppercaseString
        }
        else{
            if indexPath.section == 0 {
                label.text = self.lookings[indexPath.row].uppercaseString
            }
            else {
                label.text = self.offers[indexPath.row].uppercaseString
            }
        }

        label.sizeToFit()
        return CGSizeMake(label.bounds.width + 10.0, 22.0)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if collectionView == industryCollectionView{
            return 1
        }
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == industryCollectionView{
            if industries.count > 2{
                return 2
            }
            
            return industries.count
        }
        if section == 0 {
            if lookings.count > 2{
                return 2
            }
            return lookings.count
        }
        
        if self.offers.count > 2{
            return 2
        }
        return self.offers.count
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "discoveryReusableView", forIndexPath: indexPath) as! DiscoveryHeaderView

        if indexPath.section == 0 {
            view.mainLabel.text = "I am looking for"
        }
        else {
            view.mainLabel.text = "I can offer"
        }
        return view
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionViewCell", forIndexPath: indexPath) as! InterestCollectionViewCell
        
        if collectionView == industryCollectionView{
            cell.interestLabel.text = self.industries[indexPath.row].uppercaseString
            
            if matchedIndustryArray.count == 0{
                cell.backgroundColor = UIColor(red: 35/255.0, green: 149/255.0, blue: 175/255.0, alpha: 1.0)
                cell.interestLabel.textColor = UIColor.whiteColor()
                
                cell.interestLabel.textAlignment = .Center
                return cell
            }
            
            if matchedIndustryArray[indexPath.row] == 1{
                cell.backgroundColor = UIColor.whiteColor()
                cell.interestLabel.textColor = UIColor(red: 77/255.0, green: 77/255.0, blue: 77/255.0, alpha: 1.0)
            }
            else{
                cell.backgroundColor = UIColor.clearColor()
                cell.interestLabel.textColor = UIColor.whiteColor()
                
                cell.layer.borderWidth = 1.0
            }
            cell.layer.borderColor = UIColor.whiteColor().CGColor
            
            cell.interestLabel.textAlignment = .Center
            return cell
        }
        
        if indexPath.section == 0 {
            cell.interestLabel.text = self.lookings[indexPath.row].uppercaseString
            
            if matchedLookingArray.count == 0{
                cell.backgroundColor = UIColor(red: 35/255.0, green: 149/255.0, blue: 175/255.0, alpha: 1.0)
                cell.interestLabel.textColor = UIColor.whiteColor()
                
                cell.interestLabel.textAlignment = .Center
                return cell
            }
            
            if matchedLookingArray[indexPath.row] == 1{
                cell.backgroundColor = UIColor(red: 35/255.0, green: 149/255.0, blue: 175/255.0, alpha: 1.0)
                cell.interestLabel.textColor = UIColor.whiteColor()
            }
            else{
                cell.backgroundColor = UIColor.clearColor()
                cell.interestLabel.textColor = UIColor(red: 35/255.0, green: 149/255.0, blue: 175/255.0, alpha: 1.0)
                
                cell.layer.borderWidth = 1.0
            }
            cell.layer.borderColor = UIColor(red: 35/255.0, green: 149/255.0, blue: 175/255.0, alpha: 1.0).CGColor
            //cell.backgroundColor = UIColor(red: 35/255.0, green: 149/255.0, blue: 175/255.0, alpha: 1.0)
        }
        else {
            cell.interestLabel.text = self.offers[indexPath.row].uppercaseString
            // cell.backgroundColor = UIColor(red: 32/255.0, green: 55/255.0, blue: 86/255.0, alpha: 1.0)
            
            if matchedOfferArray.count == 0{
                cell.backgroundColor = UIColor(red: 35/255.0, green: 149/255.0, blue: 175/255.0, alpha: 1.0)
                cell.interestLabel.textColor = UIColor.whiteColor()
                
                cell.interestLabel.textAlignment = .Center
                return cell
            }
            
            if matchedOfferArray[indexPath.row] == 1{
                cell.backgroundColor = UIColor(red: 32/255.0, green: 55/255.0, blue: 86/255.0, alpha: 1.0)
                cell.interestLabel.textColor = UIColor.whiteColor()
            }
            else{
                cell.backgroundColor = UIColor.clearColor()
                cell.interestLabel.textColor = UIColor(red: 32/255.0, green: 55/255.0, blue: 86/255.0, alpha: 1.0)
                
                cell.layer.borderWidth = 1.0                
            }
            cell.layer.borderColor = UIColor(red: 32/255.0, green: 55/255.0, blue: 86/255.0, alpha: 1.0).CGColor
        }

        cell.interestLabel.textAlignment = .Center
        return cell
    }
}