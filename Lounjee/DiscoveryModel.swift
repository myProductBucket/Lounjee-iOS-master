//
//  DiscoveryModel.swift
//  
//
//  Created by Junior Boaventura on 31.03.16.
//
//

import Foundation
struct DiscoveryModel {
    typealias DiscoveryModelCompletion = ((result: [String: AnyObject], error: APIError) -> Void)
    
    static func PostAcceptMatch(matchId: Int) {
        let acceptMatch = APIRouter.PostAcceptMatch(matchId: matchId)
        APIManager.sendRequest(acceptMatch) { (result, error) in
            // To Do
        }
    }

    static func PostRefuseMatch(matchId: Int) {
        let refuseMatch = APIRouter.PostRefuseMatch(matchId: matchId)
        APIManager.sendRequest(refuseMatch) { (result, error) in
            // To Do
        }
    }
    
    static func GetPotentialMatches(completion:((result: [UserModel], error: APIError) -> Void)) {
        var data = [UserModel]()
        let potentialMatches = APIRouter.GetPotentialMatches()

        APIManager.sendRequest(potentialMatches) { (result, error) in
            if let users = result["users"] as? [[String:AnyObject]]  {
                for user in users {
                    data.append(UserModel(dictionary: user))
                }
                completion(result: data, error: error)
            }
        }
    }
    
    static func PostIgnoreMatch(userId: Int) {
        let ignoreMatch = APIRouter.PostIgnoreMatch(userId: userId)

        APIManager.sendRequest(ignoreMatch) { (result, error) in
            // To Do
        }
    }
    
    static func PostRequestMatch(user: UserModel,reason: String) {
        let requestMatch = APIRouter.PostRequestMatch(userId: user.id!, purpose: reason)
        APIManager.sendRequest(requestMatch) { (result, error) in
//            completion(result: result, error: error)
        }
    }
    
    static func GetRequestedMatches(completion:((result: [RequestMatchModel], error: APIError) -> Void)) {
        let GetRequestedMatches = APIRouter.GetRequestedMatches()

        APIManager.sendRequest(GetRequestedMatches) { (result, error) in
            var data = [RequestMatchModel]()

            if let requests = result["requestMatches"] as? [[String:AnyObject]]  {
                for request in requests {
                    data.append(RequestMatchModel(dictionary: request))
                }
            }
            completion(result: data, error: error)
        }
    }
}