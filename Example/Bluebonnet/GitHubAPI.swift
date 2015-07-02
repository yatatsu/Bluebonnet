//
//  GitHubAPI.swift
//  Bluebonnet
//
//  Created by kitagawa on 2015/07/02.
//  Copyright (c) 2015年 CocoaPods. All rights reserved.
//

import Foundation
import Bluebonnet

/**
 Here is sample implementation with Bluebonnet
*/
public class GitHubAPI: Bluebonnet {
    
    // baseURL for all api
    static let baseURL: NSURL = NSURL(string: "https://api.github.com")!
    
    /**
     for respective API
    */
    struct GetUserProfile: BluebonnetRequest {
        typealias Response = User
        typealias ErrorResponse = GitHubError
        let userName: String
        let method: HTTPMethod = .GET
        var parameters: [String: AnyObject] = [:]
        var path: String {
            return "users/\(userName.URLEscapedString)"
        }
        
        init(userName: String) {
            self.userName = userName
        }
        
        /// it is requred property for converting to request
        var URLRequest: NSURLRequest {
            return Bluebonnet.build(baseURL, path: path, method: method, parameters: parameters)
        }
    }
    
    public enum ReposSort: String {
        case Pushed = "pushed"
        case Created = "created"
        case Updated = "updated"
        
        static let key: String = "sort"
    }
    
    struct GetUserRepos: BluebonnetRequest {
        typealias Response = Repos
        typealias ErrorResponse = GitHubError
        let userName: String
        let sort: ReposSort
        let method: HTTPMethod = .GET
        var parameters: [String: AnyObject] {
            return [ReposSort.key: sort.rawValue]
        }
        var path: String {
            return "users/\(userName.URLEscapedString)/repos"
        }
        
        init(userName: String, sort: ReposSort) {
            self.userName = userName
            self.sort = sort
        }
        
        var URLRequest: NSURLRequest {
            return Bluebonnet.build(baseURL, path: path, method: method, parameters: parameters)
        }
    }
}


// MARK: - String extension

private extension String {
    var URLEscapedString: String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
    }
}


