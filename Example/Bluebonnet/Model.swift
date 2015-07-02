//
//  Model.swift
//  Bluebonnet
//
//  Created by kitagawa on 2015/07/02.
//  Copyright (c) 2015年 CocoaPods. All rights reserved.
//

import Foundation
import Bluebonnet
import SwiftyJSON

struct Repo {
    let id: Int
    let name: String
    let description: String?
    let ownerName: String?
    let isPrivate: Bool
    let language: String?
    let star: Int
    let homepage: String?
}

class Repos: DataConvertable {
    let repos: [Repo]
    
    init(data: AnyObject) {
        if let items = JSON(data).array {
            repos = items.map { (item: JSON) -> Repo in
                return Repo(id: item["id"].intValue,
                    name: item["name"].stringValue,
                    description: item["description"].string,
                    ownerName: item["owner"]["login"].string,
                    isPrivate: item["private"].boolValue,
                    language: item["language"].string,
                    star: item["stargazers_count"].intValue,
                    homepage: item["homepage"].string)
            }
        } else {
            repos = []
        }
    }
    
    static func convert(response: NSHTTPURLResponse, data: AnyObject) -> Repos? {
        return Repos(data: data)
    }
}

class User: DataConvertable {
    let id: Int?
    let name: String?
    let url: String?
    let htmlUrl: String?
    let blog: String?
    let email: String?
    let hireable: Bool?
    let bio: String?
    let repos: Int?
    let followers: Int?
    
    init(data: AnyObject) {
        let json = JSON(data)
        id = json["id"].int
        name = json["login"].string
        url = json["url"].string
        htmlUrl = json["html_url"].string
        blog = json["blog"].string
        email = json["email"].string
        hireable = json["hireable"].bool
        bio = json["bio"].string
        repos = json["public_repos"].int
        followers = json["followers"].int
    }
    
    static func convert(response: NSHTTPURLResponse, data: AnyObject) -> User? {
        return User(data: data)
    }
}

class GitHubError: ErrorDataConvertable {
    let documentationUrl: String?
    let message: String?
    
    init(JSON: AnyObject) {
        documentationUrl = JSON["documentation_url"] as? String
        message = JSON["message"] as? String
    }
    
    var customError: NSError? {
        let userInfo = message.map { ["message":$0] }
        return NSError(domain: "com.github.api", code: 1000, userInfo: userInfo)
    }
    
    static func convert(response: NSHTTPURLResponse, data: AnyObject) -> GitHubError? {
        return GitHubError(JSON: data)
    }
}