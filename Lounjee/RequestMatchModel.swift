//
//  RequestMatchModel.swift
//  Lounjee
//
//  Created by Junior Boaventura on 01.04.16.
//  Copyright © 2016 Junior. All rights reserved.
//

import Foundation

struct RequestMatchModel {
    typealias RequestMatchModelCompletion = ((result: [String: AnyObject], error: APIError) -> Void)
    
    var id: Int!
    var createdAt:NSDate
    var updatedAt:NSDate
    var userId:Int
    var requestUserId:Int
    var purpose:String?
    var state:Int
    var requestUser:UserModel
    
    init(dictionary: [String: AnyObject]) {
        self.id = dictionary["id"] as! Int
        self.createdAt = APIManager.dateFromString(dictionary["createdAt"] as! String)!
        self.updatedAt = APIManager.dateFromString(dictionary["updatedAt"] as! String)!
        self.userId = dictionary["userId"] as! Int
        self.requestUserId = dictionary["requestUserId"] as! Int
        self.purpose = dictionary["purpose"] as? String
        self.state = dictionary["state"] as! Int
        
        let user = dictionary["requestUser"] as! [String:AnyObject]
        self.requestUser = UserModel.init(dictionary: user)
    }
    
    func acceptMatch(completion: RequestMatchModelCompletion) {
        let acceptMatch = APIRouter.PostAcceptMatch(matchId: self.id)
        APIManager.sendRequest(acceptMatch) { (result, error) in
            completion(result: result, error: error)
        }
    }
    
    func refuseMatch(completion: RequestMatchModelCompletion) {
        let refuseMatch = APIRouter.PostRefuseMatch(matchId: self.id)
        APIManager.sendRequest(refuseMatch) { (result, error) in
            completion(result: result, error: error)
        }
    }
    
}