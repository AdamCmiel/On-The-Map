//
//  APIActions.swift
//  On The Map
//
//  Created by Adam Cmiel on 11/1/15.
//  Copyright © 2015 Adam Cmiel. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit

//let parseHeaders = [
//    "x-parse-rest-api-key": "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY",
//    "x-parse-application-id": "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
//]

let parseHeaders: [String: String]? = NSBundle.mainBundle().infoDictionary?["ParseHeaders"] as? [String: String]

struct APIActions {
    
    // MARK: - User Sessions
    
    static func signIn(email email: String, password: String, completion: APICallback) {
        let data = [
            "udacity": [
                "username": email,
                "password": password
            ]
        ]
        
        API.post(.SignIn, data, completion: completion)
    }
    
    static func signOut(completion: APICallback) {
        if FBSDKAccessToken.currentAccessToken() != nil {
            FBSDKLoginManager().logOut()
            completion(.Success([:]))
        } else {
            API.delete(.SignOut, nil, completion: completion)
        }
    }
    
    static func facebookLogInFromViewController(viewController: UIViewController, completion: APICallback) {
        
        // if there is a valid session
        let token = FBSDKAccessToken.currentAccessToken()
        if token != nil {
            completion(.Success(["token": token.tokenString]))
        }
        
        let login = FBSDKLoginManager()
        login.loginBehavior = .Native
        login.logInWithReadPermissions(["public_profile"], fromViewController: viewController) { result, error in
            
            if ((error) != nil) {
                
                completion(.Failure(APIError(errorType: .Network, error: error)))
                return
                
            } else if result.isCancelled {
                
                completion(.Failure(APIError(errorType: .Cancelled, error: nil)))
                return
                
            } else {
                
                let token = FBSDKAccessToken.currentAccessToken()
                let tokenString: String = token.tokenString
                
                let fbRequest = FBSDKGraphRequest(graphPath:"me", parameters: nil);
                fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
                    
                    guard error == nil else {
                        print("Error Getting Info \(error)");
                        return
                    }
                    
                    let name = result["name"] as! String
                    let names = name.componentsSeparatedByString(" ")
                    let firstName = names.first
                    let lastName = names.last
                    
                    StudentDataStore.sharedStore.firstName = firstName
                    StudentDataStore.sharedStore.lastName = lastName
                }
                
                API.post(.SignIn, ["facebook_mobile": ["access_token": tokenString]]) { response in
                    switch response {
                    case .Success(let body):
                        
                        // NSURLSession.sharedSession gets cookie from API response
                        completion(.Success(body))
                        
                    case .Failure(let error):
                        
                        completion(.Failure(error))
                        return
                    }
                }
                
            }
        }
    }
    
    // MARK: Parse API
    
    static func getStudentLocations(completion: APICallback) {
        API.get(.StudentLocations, headers: parseHeaders, completion: completion)
    }
    
    static func postStudentLocation(var data: JSONData, completion: APICallback) {
        
        if data["url"] == nil {
            data["url"] = "https://www.udacity.com"
        }
        
        API.post(.StudentLocations, data, headers: parseHeaders, completion: completion)
    }
}
