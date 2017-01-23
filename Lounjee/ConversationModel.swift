//
//  ConversationModel.swift
//  Lounjee
//
//  Created by Junior Boaventura on 31.03.16.
//  Copyright © 2016 Junior. All rights reserved.
//

import Foundation

struct ConversationModel {
    var id:Int!
    let createdAt:NSDate
    let updatedAt:NSDate

    var receiver: UserModel
    let lastSentMessageAt:NSDate?

    var messages = [MessageModel]()
    
    init(dictionary: [String: AnyObject]) {
        self.id = dictionary["id"] as! Int
        self.createdAt = APIManager.dateFromString(dictionary["createdAt"] as! String)!
        self.updatedAt = APIManager.dateFromString(dictionary["updatedAt"] as! String)!

        let user = dictionary["receiver"] as! [String: AnyObject]
        self.receiver = UserModel.init(dictionary: user)
        
        self.lastSentMessageAt = dictionary["lastSentMessageAt"] as? NSDate

        if let _messages = dictionary["messages"] as? [[String:AnyObject]] {
            for message in _messages {
                self.messages.append(MessageModel(dictionary: message))
            }
        }
    }

    static func getConversations(completion:((result: [ConversationModel], error: APIError) -> Void)) {
        let getConversation = APIRouter.GetConversations()

        APIManager.sendRequest(getConversation) { (result, error) in
            var data = [ConversationModel]()

            if let requests = result["conversations"] as? [[String:AnyObject]]  {
                for request in requests {
                    data.append(ConversationModel(dictionary: request))
                }
            }
            
            completion(result: data, error: error)
        }
    }

    mutating func PostMessage(message: String, completion:((result: [MessageModel], error: APIError) -> Void)) {
        let postMessage = APIRouter.PostMessage(conversationId: self.id, content: message)

        APIManager.sendRequest(postMessage) { (result, error) in
            self.updateMessages({ (result, error) in
                completion(result: result, error: error)
            })
        }
    }

    mutating func updateMessages(completion:((result: [MessageModel], error: APIError) -> Void)) {
        let getConversationById = APIRouter.GetConversationById(self.id)

        APIManager.sendRequest(getConversationById) { (result, error) in
            var data = [MessageModel]()
            
            if let _messages = result["messages"] as? [[String:AnyObject]] {
                
                for message in _messages {
                    data.append(MessageModel(dictionary: message))
                }
            
                self.messages = data
            }
            completion(result: data, error: error)
        }
    }

    func getLastMessage() -> String {
        if let message = self.messages.last {
            return message.content
        }
        return " "
    }
    
    func getLastMessageAuthor() -> Int{
        if let message = self.messages.last{
            return message.authorId
        }
        return 0
    }
    
    func getLastMessageUpdatedDate() -> NSDate{
        if let message = self.messages.last{
            return message.updatedAt
        }
        
        return (self.messages.last?.updatedAt)!
    }
}