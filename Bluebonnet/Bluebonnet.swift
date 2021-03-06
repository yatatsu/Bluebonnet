//
//  Bluebonnet.swift
//  Bluebonnet
//
//  Created by yatatsu on 2015/07/02.
//
//

import Foundation
import Alamofire
import SwiftTask

// MARK: - Common Types

/// SwiftTask.Progress
public typealias Progress = (bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
/// Alamofire.Request.Serializer
public protocol ResponseSerializer {
    typealias SerializedObject
    var serializeResponse: (NSURLRequest, NSHTTPURLResponse?, NSData?) -> (SerializedObject?, NSError?) { get }
}

/// Alamofire.Request.Validation
public typealias Validation = (NSURLRequest, NSHTTPURLResponse) -> Bool

/// domain for Bluebonnet errors
public let BluebonnetErrorDomain = "com.bluebonnet.error"

// MARK: - Request Interface

public protocol BluebonnetRequest: URLRequestConvertible {
    typealias Response: DataConvertable
    typealias ErrorResponse: DataConvertable
    var path: String { get }
    var method: Bluebonnet.HTTPMethod { get }
    var parameters: [String: AnyObject] { get }
}

/**
type for response object.
*/
public protocol DataConvertable {
    typealias ConvertableType = Self
    static func convert(response: NSHTTPURLResponse, data: AnyObject) -> ConvertableType?
}

// MARK: - API Interface

public class Bluebonnet {
    
    /// original is Alamofire.Method
    public enum HTTPMethod: String {
        case GET = "GET"
        case POST = "POST"
        case PUT = "PUT"
        case HEAD = "HEAD"
        case DELETE = "DELETE"
        case PATCH = "PATCH"
        case TRACE = "TRACE"
        case OPTIONS = "OPTIONS"
        case CONNECT = "CONNECT"
    }
    
    public class var unexpectedError: NSError? {
        get {
            return NSError(domain: BluebonnetErrorDomain, code: 0, userInfo: nil)
        }
    }
    
    // you can customise in subclass
    public class func requestValidation<T: BluebonnetRequest>(api: T) -> Validation? {
        return nil
    }
    
    // you can customise in subclass
    public class func typedSerializer<T: BluebonnetRequest>(api: T) -> GenericResponseSerializer<AnyObject> {
        return GenericResponseSerializer<AnyObject> { (request, response, data) in
            let JSONSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let (JSON: AnyObject?, serializationError) = JSONSerializer.serializeResponse(request, response, data)
            if let response = response, JSON: AnyObject = JSON {
                if response.statusCode < 400 {
                    return (T.Response.convert(response, data: JSON) as? AnyObject, nil)
                } else{
                    return (T.ErrorResponse.convert(response, data: JSON) as? AnyObject, nil)
                }
            } else {
                return (nil, serializationError)
            }
        }
    }
    
    public class func build(baseURL: NSURL, path: String, method: HTTPMethod, parameters: [String:AnyObject]?)
        -> NSURLRequest {
        var req: NSMutableURLRequest = NSMutableURLRequest(URL: baseURL.URLByAppendingPathComponent(path))
        req.HTTPMethod = method.rawValue
        let encoding = Alamofire.ParameterEncoding.URL
        return encoding.encode(req, parameters: parameters).0
    }
    
    public class func requestTask<T: BluebonnetRequest>(api: T)
        -> Task<Progress, T.Response, (error: NSError, response: T.ErrorResponse?)> {
        let responseSerializer = typedSerializer(api)
        let unexpectedError: NSError? = self.unexpectedError
        let customValidation = self.requestValidation(api)
        let task = Task<Progress, T.Response, (error: NSError, response: T.ErrorResponse?)> {
            (progress, fulfill, reject, configure) in
            let request = Alamofire.request(api)
                .progress { bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
                    progress((bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) as Progress)
                }
            if let validation = customValidation {
                request.validate(validation)
            } else {
                request.validate()
            }
            request.response(responseSerializer: responseSerializer,
                completionHandler: {
                    (request, response, object: T.Response?, errorObject: T.ErrorResponse?, error) in
                    if let error = error {
                        reject(error: error, response: errorObject)
                        return
                    }
                    if let object = object {
                        fulfill(object)
                        return
                    }
                    reject(error: unexpectedError ?? NSError(), response: errorObject)
            })
            configure.pause = { request.suspend() }
            configure.resume = { request.resume() }
            configure.cancel = { request.cancel() }
        }
        return task
    }
}

// MARK: - Alamofire extension

extension Alamofire.Request {
    public func response<T: DataConvertable, E: DataConvertable>(
        responseSerializer serializer: GenericResponseSerializer<AnyObject>,
        completionHandler: (NSURLRequest, NSHTTPURLResponse?, T?, E?, NSError?) -> Void) -> Self {
        return response(responseSerializer: serializer, completionHandler: {
            (request, response, object, error) -> Void in
            switch object {
            case _ as T:
                completionHandler(request, response, object as? T, nil, error)
            default:
                completionHandler(request, response, nil, object as? E, error)
            }
        })
    }
}
