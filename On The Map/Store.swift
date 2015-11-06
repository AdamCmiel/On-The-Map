//
//  Store.swift
//  Pods
//
//  Created by Adam Cmiel on 11/5/15.
//
//

import Foundation


class Store {
    var sharedStore: Store {
        get {
            return Store()
        }
    }
}
