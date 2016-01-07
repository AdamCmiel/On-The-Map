//
//  TabViewController.swift
//  On The Map
//
//  Created by Adam Cmiel on 1/6/16.
//  Copyright © 2016 Adam Cmiel. All rights reserved.
//

import UIKit

class TabViewController: UIViewController {
    var store: StudentDataStore {
        get { return StudentDataStore.sharedStore }
    }

    final func alert(error: NSError) {
        let alert = UIAlertController(title: "Error", message: error.domain, preferredStyle: .Alert)
        let okButton = UIAlertAction(title: "OK", style: .Default) { _ in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        alert.addAction(okButton)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: UIViewController
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if store.hasUdacitySession {
            let tbc = tabBarController as! TabBarController
            tbc.refeshData(self)
        }
    }
}
