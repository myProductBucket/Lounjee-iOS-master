//
//  FavoriteModel.swift
//  Lounjee
//
//  Created by Daniel Drescher on 01/09/16.
//  Copyright © 2016 Junior. All rights reserved.
//

import Foundation
struct FavoriteModel {
    typealias FavoriteModelCompletion = ((result: [String: AnyObject], error: APIError) -> Void)
    
    static func DeleteFavorite(favoriteUserID: Int) {
        let deleteFavorite = APIRouter.DeleteFavorite(favoriteUserID: favoriteUserID)
        
        APIManager.sendRequest(deleteFavorite) { (result, error) in
            // To Do
        }
    }
    
    static func PostFavorite(favoriteUserID: Int,reason: String) {
        let postFavorite = APIRouter.PostFavorite(favoriteUserID: favoriteUserID)
        APIManager.sendRequest(postFavorite) { (result, error) in
            //            completion(result: result, error: error)
        }
    }
    
    static func GetFavorites(completion:((result: [UserModel], error: APIError) -> Void)) {
        let getFavorites = APIRouter.GetFavorite()
        
        APIManager.sendRequest(getFavorites) { (result, error) in
            var data = [UserModel]()
            
            if let requests = result["userFavorites"] as? [[String:AnyObject]]  {
                for request in requests {
                    if let items = request["favoriteUser"] as? [String:AnyObject] {
                        data.append(UserModel(dictionary: items))
                    }
                    print("FavoriteUserID: \(request["favoriteUserId"])")
                }
            }
            completion(result: data, error: error)
        }
    }
}