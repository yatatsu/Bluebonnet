//
//  BluebonnetTests.swift
//  Bluebonnet
//
//  Created by KITAGAWA Tatsuya on 2015/07/03.
//  Copyright (c) 2015年 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
import Bluebonnet
import OHHTTPStubs
import SwiftTask

class BluebonnetTests: XCTestCase {

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    func testSuccessResopnse() {
        let data = NSJSONSerialization
            .dataWithJSONObject(["name":"Bluebonnet"], options: .PrettyPrinted, error: nil)!
        
        OHHTTPStubs.stubRequestsPassingTest({ _ in
            return true
        }, withStubResponse: { _ in
            return OHHTTPStubsResponse(data: data, statusCode: 200, headers: nil)
        })
        
        let expectation = expectationWithDescription("ready")
        let task = TestAPI.requestTask(TestAPI.GetMock())
        task.success { response in
            XCTAssert("Bluebonnet" == response.name)
            expectation.fulfill()
        }
        .failure { (error, isCancelled) -> Void in
            XCTFail()
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testFailureWithNetworkError() {
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil)
        
        OHHTTPStubs.stubRequestsPassingTest({ _ in
            return true
        }, withStubResponse: { _ in
            return OHHTTPStubsResponse(error:error)
        })
        
        let expectation = expectationWithDescription("ready")
        let task = TestAPI.requestTask(TestAPI.GetMock())
        task.success { _ in
            XCTFail()
            expectation.fulfill()
        }
        .failure { (errorResult, isCancelled) -> Void in
            XCTAssert(errorResult?.error.domain == NSURLErrorDomain)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testFailureWithErrorResponse() {
        let data = NSJSONSerialization
            .dataWithJSONObject(["message":"Not Found"], options: .PrettyPrinted, error: nil)!
        
        OHHTTPStubs.stubRequestsPassingTest({ _ in
            return true
        }, withStubResponse: { _ in
            return OHHTTPStubsResponse(data: data, statusCode: 404, headers: nil)
        })
        
        let expectation = expectationWithDescription("ready")
        let task = TestAPI.requestTask(TestAPI.GetMock())
        task.success { _ in
            XCTFail()
            expectation.fulfill()
        }
        .failure { (errorResult, isCancelled) -> Void in
            XCTAssert(errorResult?.response?.message == "Not Found")
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testFailureWithSerializeError() {
        let data = "Error String".dataUsingEncoding(NSUTF8StringEncoding)!
        
        OHHTTPStubs.stubRequestsPassingTest({ _ in
            return true
            }, withStubResponse: { _ in
                return OHHTTPStubsResponse(data: data, statusCode: 200, headers: nil)
        })
        
        let expectation = expectationWithDescription("ready")
        let task = TestAPI.requestTask(TestAPI.GetMock())
        task.success { _ in
            XCTFail()
            expectation.fulfill()
        }
        .failure { (errorResult, isCancelled) -> Void in
            XCTAssert(errorResult?.error.domain == NSCocoaErrorDomain)
            XCTAssert(errorResult?.error.code == 3840)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testFailureWithDecodeError() {
        let data = NSJSONSerialization
            .dataWithJSONObject([:], options: .PrettyPrinted, error: nil)!
        
        OHHTTPStubs.stubRequestsPassingTest({ _ in
            return true
        }, withStubResponse: { _ in
            return OHHTTPStubsResponse(data: data, statusCode: 200, headers: nil)
        })
        
        let expectation = expectationWithDescription("ready")
        let task = TestAPI.requestTask(TestAPI.GetMock())
        task.success { _ in
            XCTFail()
            expectation.fulfill()
            }
        .failure { (errorResult, isCancelled) -> Void in
            XCTAssert(errorResult?.error.domain == TestAPI.unexpectedError?.domain)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testFailureWithCancel() {
        let data = NSJSONSerialization
            .dataWithJSONObject(["name":"Bluebonnet"], options: .PrettyPrinted, error: nil)!
        
        OHHTTPStubs.stubRequestsPassingTest({ _ in
            return true
        }, withStubResponse: { _ in
            return OHHTTPStubsResponse(data: data, statusCode: 200, headers: nil)
        })
        
        let expectation = expectationWithDescription("ready")
        let task = TestAPI.requestTask(TestAPI.GetMock())
        task.cancel()
        task.success { response in
            XCTFail()
            expectation.fulfill()
        }
        .failure { (error, isCancelled) -> Void in
            XCTAssert(isCancelled)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testRequestParam() {
        func dataWithName(name: String) -> NSData {
            return NSJSONSerialization
                .dataWithJSONObject(["name":name], options: .PrettyPrinted, error: nil)!
        }
        
        OHHTTPStubs.stubRequestsPassingTest({ _ in
            return true
        }, withStubResponse: { (request: NSURLRequest) -> OHHTTPStubsResponse in
            if let query = request.URL?.query {
                return OHHTTPStubsResponse(data: dataWithName(query), statusCode: 200, headers: nil)
            } else {
                let data = NSJSONSerialization
                    .dataWithJSONObject(["message":"Not Found"], options: .PrettyPrinted, error: nil)!
                return OHHTTPStubsResponse(data: data, statusCode: 404, headers: nil)
            }
        })
        
        let expectation = expectationWithDescription("ready")
        let task = TestAPI.requestTask(TestAPI.GetParam(name: "Bluebonnet"))
        task.success { response in
            XCTAssert("name=Bluebonnet" == response.name)
            expectation.fulfill()
        }
        .failure { (error, isCancelled) -> Void in
            XCTFail()
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testFailureValidation() {
        let data = NSJSONSerialization
            .dataWithJSONObject(["name":"Bluebonnet"], options: .PrettyPrinted, error: nil)!
        
        OHHTTPStubs.stubRequestsPassingTest({ _ in
            return true
        }, withStubResponse: { _ in
            return OHHTTPStubsResponse(data: data, statusCode: 200, headers: nil)
        })
        
        let expectation = expectationWithDescription("ready")
        let task = TestAPI.requestTask(TestAPI.GetMockValidation())
        task.success { response in
            XCTFail()
            expectation.fulfill()
        }
        .failure { (errorResult, isCancelled) -> Void in
            XCTAssert(errorResult?.error.code == -1)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testSuccessValidation() {
        let data = NSJSONSerialization
            .dataWithJSONObject(["name":"Bluebonnet"], options: .PrettyPrinted, error: nil)!
        
        OHHTTPStubs.stubRequestsPassingTest({ _ in
            return true
        }, withStubResponse: { _ in
            return OHHTTPStubsResponse(data: data, statusCode: 200, headers: ["validation":"ok"])
        })
        
        let expectation = expectationWithDescription("ready")
        let task = TestAPI.requestTask(TestAPI.GetMockValidation())
        task.success { response in
            XCTAssert("ok" == response.validated as? String)
            expectation.fulfill()
        }
        .failure { (error, isCancelled) -> Void in
            XCTFail()
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }

}