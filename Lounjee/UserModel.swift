    //
//  UserModel.swift
//  Lounjee
//
//  Created by Junior Boaventura on 18.03.16.
//  Copyright © 2016 Junior. All rights reserved.
//

import Foundation
import CoreLocation

struct UserModel {
    var synchronised: Bool = false
    var id:Int?
    var firstName: String?
    var lastName: String?
    var emailAddress: String?
    var headline: String?
    var city: String?
    var country: String?
    var publicProfileUrl: String?
    var pictureUrl: String?
    var specialties: String?
    var industry: String?
    var token: String?
    var deviceToken: String?
    var numConnections: String?
    var numRecommenders: String?
    
    var educations: [AnyObject]?
    var companies: [AnyObject]?
    var lookings: [[String: AnyObject]]?
    var offers: [[String: AnyObject]]?
    var industries: [[String: AnyObject]]?

    var latitude: Double?
    var longitude: Double?
    var distance: Double?
    var summary: String?
    
    var lookingsCode:[Int]?
    var offersCode:[Int]?
    var industriesCode: [Int]?
    var linkedinId:String?
    
    init(dictionary: [String: AnyObject]) {
        if let _id = dictionary["id"] as? String {
            self.id = Int(_id)
        }
        
        if let _id = dictionary["id"] as? Int {
            self.id = _id
        }
        
        self.linkedinId = dictionary["linkedinId"] as? String

        self.firstName = dictionary["firstName"] as? String
        self.lastName = dictionary["lastName"] as? String
        self.emailAddress = dictionary["emailAddress"] as? String
        self.headline = dictionary["headline"] as? String
        
        if let location = dictionary["location"] as? [String: AnyObject], let country = location["country"] as? [String: AnyObject], let code = country["code"] as? String {
            self.city = location["name"] as? String
            self.country = code
        } else {
            self.city = dictionary["city"] as? String
            self.country = dictionary["country"] as? String
        }
        
        self.deviceToken = dictionary["deviceToken"] as? String
        self.publicProfileUrl = dictionary["publicProfileUrl"] as? String

        if let picture = dictionary["pictureUrls"] as? [String: AnyObject], let values = picture["values"] as? [String] {
            self.pictureUrl = values.first
        }
        else if let picture = dictionary["pictureUrl"] as? String {
            self.pictureUrl = picture
        }
        else {
            self.pictureUrl = nil
        }
    
        self.specialties = dictionary["specialties"] as? String
        self.industry = dictionary["industry"] as? String
        
        self.token = dictionary["token"] as? String
        self.numConnections = dictionary["numConnections"] as? String
        self.numRecommenders = dictionary["numRecommenders"] as? String
        self.summary = dictionary["summary"] as? String
        
        
        if  let _lat = dictionary["latitude"] as? String {
            self.latitude = Double(_lat)
        }
        
        if let _long = dictionary["longitude"] as? String {
            self.longitude = Double(_long)
        }
        
        if let _dist = dictionary["distance"] as? String {
            self.distance = Double(_dist)
        }


        self.educations = nil
        self.companies = nil
        
        self.lookings = dictionary["lookings"] as? [[String: AnyObject]]
        self.offers = dictionary["offers"] as? [[String: AnyObject]]
        self.industries = dictionary["industries"] as? [[String: AnyObject]]
    }
    
    func toDictionary() -> [String: AnyObject] {
        var data = [String:AnyObject]()
        data["deviceToken"] = self.deviceToken
        data["firstName"] = self.firstName
        data["lastName"] = self.lastName
        data["emailAddress"] = self.emailAddress
        data["headline"] = self.headline
        data["city"] = self.city
        data["country"] = self.country
        data["publicProfileUrl"] = self.publicProfileUrl
        data["pictureUrl"] = self.pictureUrl
        data["specialties"] = self.specialties
        data["industry"] = self.industry
        data["token"] = self.token
        data["numConnections"] = self.numConnections
        data["numRecommenders"] = self.numRecommenders
        data["latitude"] = self.latitude
        data["longitude"] = self.longitude
        data["summary"] = self.summary
        data["educations"] = self.educations
        data["companies"] = self.companies
        data["offers"] = self.offersCode
        data["lookings"] = self.lookingsCode
        data["industries"] = self.industriesCode
        data["linkedinId"] = self.linkedinId
        return data
    }

    static func logout() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("userId")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("lounjeeToken")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("emailAddress")
    }

    func save(withCompletion completion: ((result: [String: AnyObject], error: APIError) -> Void)) {
        let createUser = APIRouter.PostUser(self.toDictionary())

        APIManager.sendRequest(createUser, withCompletion: { (result, error) -> Void in
            completion(result: result, error: error)
        })
    }
    
    static func updateLocation(id: Int, withCompletion completion: ((result: [String:AnyObject], error: APIError) -> Void)) {
        
        LocationManager.sharedInstance.getUserLocation { (location) in
            if location != nil {
                var data = [String:AnyObject]()
                data["latitude"] = location?.coordinate.latitude
                data["longitude"] = location?.coordinate.longitude
                let updateLocation = APIRouter.PatchUser(id: id, data: data)
                APIManager.sendRequest(updateLocation) { (result, error) in
                    completion(result: result, error: error)
                }
            }
        }
        
    }
        
    static func fetch(userId: Int, withCompletion completion: ((result: UserModel, error: APIError) -> Void)) {
        let getUser = APIRouter.GetUserById(userId)

        APIManager.sendRequest(getUser) { (result, error) in
            var user = UserModel.init(dictionary: result)
            user.synchronised = true
            completion(result: user, error: error)
        }
    }

    func update(withCompletion completion: ((result: [String: AnyObject], error: APIError) -> Void)) {
        let userId = NSUserDefaults.standardUserDefaults().integerForKey("userId")
        let saveUser = APIRouter.PatchUser(id: userId, data: self.toDictionary())
        
        APIManager.sendRequest(saveUser, withCompletion: { (result, error) -> Void in
            completion(result: result, error: error)
        })
    }
}
    

    
extension UserModel: Equatable {}

// MARK: Equatable

func ==(lhs: UserModel, rhs: UserModel) -> Bool {
    return lhs.id == rhs.id && lhs.emailAddress == rhs.emailAddress
}
    
    
