//
//  MessageModel.swift
//  Lounjee
//
//  Created by Junior Boaventura on 05.04.16.
//  Copyright © 2016 Junior. All rights reserved.
//

import Foundation

struct MessageModel {
    let id:Int
    let createdAt:NSDate
    let updatedAt:NSDate
    let conversationId:Int
    let authorId:Int
    let content:String
    
    init(dictionary: [String: AnyObject]) {
        self.id = dictionary["id"] as! Int
        self.createdAt = APIManager.dateFromString(dictionary["createdAt"] as! String)!
        self.updatedAt = APIManager.dateFromString(dictionary["createdAt"] as! String)!
        self.conversationId = dictionary["conversationId"] as! Int
        self.authorId = dictionary["authorId"] as! Int
        self.content = dictionary["content"] as! String
    }
    
}