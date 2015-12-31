//
//  NSURL+Swizzle.swift
//  On The Map
//
//  Created by Adam Cmiel on 12/31/15.
//  Copyright © 2015 Adam Cmiel. All rights reserved.
//

import Foundation

extension NSURL {
    static var signUpURL: NSURL {
        return NSURL(string: "https://www.udacity.com/account/auth#!/signup")!
    }
    
    private func canLoadInWebView() -> Bool {
        return scheme == "https" || scheme == "http"
    }
    
    private func replaceScheme() -> String {
        let stringValue = self.absoluteString
        return "https://\(stringValue)"
    }
    
    var sanitize: NSURL? {
        if canLoadInWebView() {
            return self
        } else {
            return NSURL(string: self.replaceScheme())
        }
    }
}