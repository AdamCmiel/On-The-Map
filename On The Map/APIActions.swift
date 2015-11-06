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

let parseHeaders = [
    "x-parse-rest-api-key": "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY",
    "x-parse-application-id": "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
]

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
        // if there is a valid session
        if FBSDKAccessToken.currentAccessToken() != nil {
            // destroy the facebook session token
        } else {
            API.delete(.SignOut, nil, completion: completion)
        }
    }
    
    static func facebookLogInFromViewController(viewController: UIViewController, completion: APICallback) {
        
        // if there is a valid session
        let token = FBSDKAccessToken.currentAccessToken()
        if token != nil {
            completion(APIResponse.Success(["token": token.tokenString]))
        }
        
        let login = FBSDKLoginManager()
        login.loginBehavior = .Native
        login.logInWithReadPermissions(["public_profile"], fromViewController: viewController) { result, error in
            
            if ((error) != nil) {
                
                completion(APIResponse.Failure(APIError(errorType: .Network, error: error)))
                return
                
            } else if result.isCancelled {
                
                completion(APIResponse.Failure(APIError(errorType: .Cancelled, error: nil)))
                return
                
            } else {
                
                let token = FBSDKAccessToken.currentAccessToken()
                let tokenString: String = token.tokenString
                
                API.post(.SignIn, ["facebook_mobile": ["access_token": tokenString]]) { response in
                    switch response {
                    case .Success(let body):
                        
                        // NSURLSession.sharedSession gets cookie from API response
                        completion(APIResponse.Success(body))
                        
                    case .Failure(let error):
                        
                        completion(APIResponse.Failure(error))
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
    
    static func postStudentLocation(completion: APICallback) {
        let postData = ["foo":"bar"]
        API.post(.StudentLocations, postData, headers: parseHeaders, completion: completion)
    }
}
