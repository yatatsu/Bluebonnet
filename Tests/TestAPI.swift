//
//  TestAPI.swift
//  Bluebonnet
//
//  Created by KITAGAWA Tatsuya on 2015/07/03.
//  Copyright (c) 2015年 CocoaPods. All rights reserved.
//

import Foundation
import Bluebonnet

class GitHubAPI: Bluebonnet {
    static let baseURL: NSURL = NSURL(string: "https://api.github.com")!
    
    struct GetMock: BluebonnetRequest  {
        typealias Response = MockResponse
        typealias ErrorResponse = MockError
        let method: HTTPMethod = .GET
        let parameters: [String:AnyObject] = [:]
        let path: String = "/mock"
        
        var URLRequest: NSURLRequest {
            return Bluebonnet.build(baseURL, path: path, method: method, parameters: parameters)
        }
    }
    
    struct GetParam: BluebonnetRequest {
        typealias Response = MockResponse
        typealias ErrorResponse = MockError
        let method: HTTPMethod = .GET
        let path: String = "/param"
        let name: String
        var parameters: [String:AnyObject] {
            return ["name":name]
        }
        
        init(name: String) {
            self.name = name
        }
        
        var URLRequest: NSURLRequest {
            return Bluebonnet.build(baseURL, path: path, method: method, parameters: parameters)
        }
    }
    
}

class MockResponse: DataConvertable {
    let name: String?

    init?(data: AnyObject) {
        self.name = data["name"] as? String
        if self.name == nil {
            return nil
        }
    }
    
    static func convert(response: NSHTTPURLResponse, data: AnyObject) -> MockResponse? {
        return MockResponse(data: data)
    }
}

class MockError: ErrorDataConvertable {
    let message: String?
    let response: NSHTTPURLResponse
    
    init(data: AnyObject, response: NSHTTPURLResponse) {
        self.message = data["message"] as? String
        self.response = response
    }
    
    var customError: NSError? {
        let userInfo = message.map { ["message":$0] }
        return NSError(domain: "com.github.api", code: 1000, userInfo: userInfo)
    }
    
    static func convert(response: NSHTTPURLResponse, data: AnyObject) -> MockError? {
        return MockError(data: data, response: response)
    }
}
