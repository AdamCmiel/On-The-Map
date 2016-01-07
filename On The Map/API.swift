//
//  API.swift
//  On The Map
//
//  Created by Adam Cmiel on 11/6/15.
//  Copyright © 2015 Adam Cmiel. All rights reserved.
//

import Foundation

internal typealias APICallback = APIResponse -> Void
internal typealias JSONData = [String: AnyObject]

enum EndPoint: String {
    case Session = "https://www.udacity.com/api/session"
    case StudentLocations = "https://api.parse.com/1/classes/StudentLocation"
    
    var isFromUdacityAPI: Bool {
        switch self {
        case .Session:
            return true
        default:
            return false
        }
    }
}


let jsonHeaders = [
    "Accept": "application/json",
    "Content-Type": "application/json"
]

enum APIErrorType {
    case Cancelled
    case Network
    case RequestJSONFormat
    case ResponseJSONFormat
    case ResponseCode
}

struct APIError {
    let errorType: APIErrorType
    let error: ErrorType?
}

enum APIResponse {
    case Success(JSONData)
    case Failure(APIError)
}

enum Method: String {
    case GET = "GET"
    case POST = "POST"
    case DELETE = "DELETE"
}

struct API {
    static func request(method: Method,
        _ URLString: EndPoint,
        parameters: [String: AnyObject]? = nil,
        headers: [String: String]? = nil,
        completion: APICallback) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: URLString.rawValue)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = method.rawValue
            
        let callback: APICallback = { response in
            dispatch_async(dispatch_get_main_queue(), { completion(response) })
        }
        
        do {
            
            if let params = parameters {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
            }
                
            if let _headers = headers {
                for (_header, _value) in _headers {
                    request.addValue(_value, forHTTPHeaderField: _header)
                }
            }
        }
        catch (let error) {
            
            callback(APIResponse.Failure(APIError(errorType: .RequestJSONFormat, error: error)))
            return
            
        }
        
        
        session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            guard error == nil else {
                
                callback(APIResponse.Failure(APIError(errorType: .Network, error: error!)))
                return
                
            }
            
            do {
                
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                switch statusCode {
                case 200...399:
                    let dataToParse = URLString.isFromUdacityAPI ? data!.subdataWithRange(NSRange(location: 5, length: data!.length - 5)) : data!
                    let json = try NSJSONSerialization.JSONObjectWithData(dataToParse, options: [.MutableLeaves, .AllowFragments]) as! JSONData
                    callback(APIResponse.Success(json))
                    return
                case 0...199:
                    fallthrough
                default:
                    callback(APIResponse.Failure(APIError(errorType: .ResponseCode, error: nil)))
                }
                
            }
            catch (let JSONError) {
                
                callback(APIResponse.Failure(APIError(errorType: .ResponseJSONFormat, error: JSONError)))
                return
                
            }
            
        }).resume()
    }
    
    static func get(endpoint: EndPoint, headers: [String: String]? = jsonHeaders, completion: APICallback) {
        return request(.GET, endpoint, parameters: nil, headers: headers, completion: completion)
    }
    
    static func post(endpoint: EndPoint, _ parameters: [String: AnyObject]? = nil, headers: [String: String]? = jsonHeaders, completion: APICallback) {
        return request(.POST, endpoint, parameters: parameters, headers: headers, completion: completion)
    }
    
    static func delete(endpoint: EndPoint, _ parameters: [String: AnyObject]? = nil, headers: [String: String]? = jsonHeaders, completion: APICallback) {
        return request(.DELETE, endpoint, parameters: parameters, headers: headers, completion: completion)
    }
}