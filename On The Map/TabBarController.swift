//
//  TabBarController.swift
//  On The Map
//
//  Created by Adam Cmiel on 11/1/15.
//  Copyright © 2015 Adam Cmiel. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !StudentDataStore.sharedStore.hasUdacitySession {
            navigationController!.performSegueWithIdentifier("showLogin", sender: self)
        }
    }
}
