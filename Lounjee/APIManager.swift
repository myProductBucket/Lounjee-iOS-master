//
//  APIManager.swift
//  Lounjee
//
//  Created by Arnaud AUBRY on 16/03/2016.
//  Copyright © 2016 Junior. All rights reserved.
//

import Foundation

enum APIRouter {

//    static let ApiBaseURL = "https://api-test.lounjee.com/"
    static let ApiBaseURL = "https://api.lounjee.com/"
    static let ApiVersion = ""
    
    //MARK: User
    case PostUser([String: AnyObject])
    case GetUserById(Int)
    case PatchUser(id: Int, data: [String: AnyObject])
    case Postlogin(linkedinId:String)
    
    //MARK: Conversation
    case PostConversation([String: AnyObject])
    case GetConversations()
    case GetConversationById(Int)
    
    //MARK: Message
    case PostMessage(conversationId:Int, content:String)
    case GetMessage(Int)
    
    //MARK: Companies
    case PostCompanies([String: AnyObject])
    
    //MARK: Industries
    case PostIndustries(id:Int, data:[Int])
    case GetIndustries(Int)
    
    //MARK: Offers
    case PostOffers(id:Int, data:[Int])
    case GetOffers(Int)
    
    //MARK: LOOKINGS
    case PostLookings(id:Int, data:[Int])
    case getLookings(Int)
    
    //MARK: GET DATA FOR SIGN IN
    case getIndustries
    case getPurposes
    
    //MARK: Match
    case GetPotentialMatches()
    case PostAcceptMatch(matchId: Int)
    case PostRefuseMatch(matchId: Int)
    case PostRequestMatch(userId: Int, purpose: String)
    case PostIgnoreMatch(userId: Int)
    case GetRequestedMatches()
    
    // MARK: Favorite
    case GetFavorite()
    case PostFavorite(favoriteUserID: Int)
    case DeleteFavorite(favoriteUserID: Int)

    var method: String {
        switch self {
        case .PostUser(_), PostConversation(_), .PostMessage(_), .PostCompanies(_), .PostIndustries(_), .PostOffers(_), .PostLookings(_), .PostAcceptMatch(_), .PostRefuseMatch(_), .PostRequestMatch(_), PostIgnoreMatch(_), .Postlogin(_), .PostFavorite(_)://, .DeleteFavorite(_):
            return "POST"
        case .GetUserById(_), .GetIndustries(_), .GetOffers(_), .getLookings(_), .GetConversations(), .GetConversationById(_), .GetMessage(_), .GetPotentialMatches(), .GetRequestedMatches(), .getIndustries, .getPurposes, .GetFavorite():
            return "GET"
        case .PatchUser(_):
            return "PATCH"
        case .DeleteFavorite(_):
            return "DELETE"
        }
    }

    var endpoint: String {
        switch self {
        case .PostUser(_):
            return "users"
        case let .GetUserById(id):
            return "users/\(id)"
        case let .PatchUser(id, _):
            return "users/\(id)"
        case Postlogin(_):
            return "login"
        case .PostConversation(_), .GetConversations():
            return "conversations"
        case let .GetConversationById(id):
            return "conversations/\(id)"
        case let .PostMessage(conversationId, _):
            return "conversations/\(conversationId)/messages"
        case let .GetMessage(id):
            return "/messages/\(id)"
        case .PostCompanies(_):
            return "companies"
        case let .PostIndustries(id, _):
            return "users/\(id)/industries"
        case let .GetIndustries(id):
            return "/users/\(id)/industries"
        case let .PostOffers(id, _):
            return "users/\(id)/offers"
        case let .GetOffers(id):
            return "/users/\(id)/offers"
        case let .PostLookings(id, _):
            return "users/\(id)/lookings"
        case let .getLookings(id):
            return "users/\(id)/lookings"
        case .GetPotentialMatches():
            return "user/matches"
        case let .PostAcceptMatch(matchId):
            return "users/\(matchId)/match/accept"
        case let .PostRefuseMatch(matchId):
            return "users/\(matchId)/match/refuse"
        case let .PostRequestMatch(userId, _):
            return "users/\(userId)/match/request"
        case let .PostIgnoreMatch(userId):
            return "users/\(userId)/match/ignore"
        case .GetRequestedMatches():
            return "user/requested/matches"
        case .getIndustries:
            return "industries"
        case .getPurposes:
            return "purposes"
        case .GetFavorite()://Favorite
            return "user/favorite"
        case let .PostFavorite(favoriteUserID)://Favorite
            return "users/\(favoriteUserID)/favorites"
        case let .DeleteFavorite(favoriteUserID)://Favorite
            return "users/\(favoriteUserID)/favorite"
        }
    }

    var URLRequest: NSURLRequest {
        let urlString = APIRouter.ApiBaseURL + APIRouter.ApiVersion + self.endpoint
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        
        request.HTTPMethod = self.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let acessToken = self.getAcessToken() {
            request.addValue(acessToken, forHTTPHeaderField: "Authorization")
        }
        
        switch self {
        case let .PostUser(parameters):
            if let json = self.encodeToJson(parameters) {
                request.HTTPBody = json
            }
        case let .PatchUser(_, data):
            if let json = self.encodeToJson(data) {
                request.HTTPBody = json
            }
        case let .PostIndustries(_, data):
            if let json = self.encodeToJson(["industries": data]) {
                request.HTTPBody = json
            }
        case let .PostFavorite(favoriteUserID):
            if let json = self.encodeToJson(["favoriteUserId": favoriteUserID]) {
                request.HTTPBody = json
            }
        case let .DeleteFavorite(favoriteUserID):
            if let json = self.encodeToJson(["favoriteUserId": favoriteUserID]) {
                request.HTTPBody = json
            }
        case let .PostOffers(_, data):
            if let json = self.encodeToJson(["offers": data]) {
                request.HTTPBody = json
            }
        case let .PostLookings(_, data):
            if let json = self.encodeToJson(["lookings": data]) {
                request.HTTPBody = json
            }
        case let .PostRequestMatch(_, reason):
            if let json = self.encodeToJson(["purpose": reason]) {
                request.HTTPBody = json
            }
        case let .PostMessage(_,content):
            let userId = NSUserDefaults.standardUserDefaults().objectForKey("userId") as! Int
            if let json = self.encodeToJson(["content": content, "author_id":userId]) {
                request.HTTPBody = json
            }
        case let .Postlogin(linkedinId):
            request.addValue(linkedinId, forHTTPHeaderField: "Authorization")
        default:
            print("No default behavior for request :" + urlString)
        }

        return request
    }
    
    // MARK: Helpers
    
    func getAcessToken() -> String? {
        if let token = NSUserDefaults.standardUserDefaults().objectForKey("lounjeeToken") as? String {
            return token
        }
        return nil
    }
    
    func encodedRequestParameters(params: [String: AnyObject]) -> NSData {
        var parametersString = ""
        params.keys.forEach({ parametersString += "\($0)=\(params[$0]!)&" })
        return NSString(string: parametersString).dataUsingEncoding(NSUTF8StringEncoding)!
    }

    func encodedURLParameters(params: [String: AnyObject]) -> String {
        var endpointString = "/"
        params.keys.forEach({ endpointString += "\(params[$0]!)" })
        return String(endpointString)
    }
    
    func encodeToJson(data: NSDictionary) -> NSData? {
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(data, options: [])
//            let json = String(data: jsonData, encoding: NSASCIIStringEncoding)
            return jsonData
        }catch {
            return nil
        }
    }
}

enum APIError {
    case None
    case Unknown
    
    case ServerError

    var message: String {
        switch self {
        case .Unknown:
            return "An unknown error has occured"
        case .ServerError:
            return "Server error"
        default:
            return ""
        }
    }
}

typealias APIManagerCompletion = ((result: [String: AnyObject], error: APIError) -> Void)

struct APIManager {
    static func sendRequest(route: APIRouter, withCompletion completion: APIManagerCompletion) {
        let request = route.URLRequest
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())

        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            do {
                var dataResult = [String: AnyObject]()

                if let data = data, let dataDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject] {
                    dataResult = dataDictionary
                }
                completion(result: dataResult, error: .None)
            } catch {
                
            }
        }
        task.resume()
    }
    
    static func dateFromString(string: String) -> NSDate? {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.locale = NSLocale.currentLocale()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        return dateFormatter.dateFromString(string)
    }
    
    static func stringFromDate(date: NSDate) -> String? {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.locale = NSLocale.currentLocale()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
        return dateFormatter.stringFromDate(date)
    }
}