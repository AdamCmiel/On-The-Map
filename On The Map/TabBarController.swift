//
//  TabBarController.swift
//  On The Map
//
//  Created by Adam Cmiel on 11/1/15.
//  Copyright © 2015 Adam Cmiel. All rights reserved.
//

import UIKit
import SafariServices

protocol Refreshing {
    func refresh(data: [StudentInformationAnnotation])
}

class TabBarController: UITabBarController, SFSafariViewControllerDelegate {
    
    @IBAction func refeshData(sender: AnyObject) {
        StudentDataStore.sharedStore.getStudentLocations { [unowned self] data in
            self.viewControllers?.forEach { vc in
                if vc is Refreshing {
                    vc.performSelector("refresh:", withObject: data)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !StudentDataStore.sharedStore.hasUdacitySession {
            //navigationController!.performSegueWithIdentifier("showLogin", sender: self)
        }
    }
    
    func presentSafariViewController(url: NSURL) {
        let webView = SFSafariViewController(URL: url)
        webView.delegate = self
        presentViewController(webView, animated: true, completion: nil)
    }
    
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        print("safari view controller finished")
    }
}
