//
//  TestAPI.swift
//  Bluebonnet
//
//  Created by KITAGAWA Tatsuya on 2015/07/03.
//  Copyright (c) 2015年 CocoaPods. All rights reserved.
//

import Foundation
import Bluebonnet

class TestAPI: Bluebonnet {
    static let baseURL: NSURL = NSURL(string: "https://api.mock.com")!

    override class var unexpectedError: NSError? {
        return NSError(domain: "com.mockapi.error", code: 0, userInfo: nil);
    }
    
    override class func requestValidation<T: BluebonnetRequest>(api: T) -> Validation? {
        switch api {
        case _ as GetMockValidation:
            return { (request: NSURLRequest, response: NSHTTPURLResponse) -> Bool in
                return response.allHeaderFields["validation"] != nil
            }
        default:
            return nil
        }
    }
    
    struct GetMockValidation: BluebonnetRequest {
        typealias Response = ValidatedResponse
        typealias ErrorResponse = MockError
        let method: HTTPMethod = .GET
        let parameters: [String:AnyObject] = [:]
        let path: String = "/validate"
        
        var URLRequest: NSURLRequest {
            return Bluebonnet.build(baseURL, path: path, method: method, parameters: parameters)
        }
    }
    
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

class MockError: DataConvertable {
    let message: String?
    let response: NSHTTPURLResponse
    
    init(data: AnyObject, response: NSHTTPURLResponse) {
        self.message = data["message"] as? String
        self.response = response
    }
    
    static func convert(response: NSHTTPURLResponse, data: AnyObject) -> MockError? {
        return MockError(data: data, response: response)
    }
}

class ValidatedResponse: DataConvertable {
    let validated: AnyObject?
    let name: String?
    
    init?(response: NSHTTPURLResponse, data: AnyObject) {
        self.validated = response.allHeaderFields["validation"]
        self.name = data["name"] as? String
        if self.name == nil {
            return nil
        }
    }
    
    static func convert(response: NSHTTPURLResponse, data: AnyObject) -> ValidatedResponse? {
        return ValidatedResponse(response: response, data: data)
    }
}
