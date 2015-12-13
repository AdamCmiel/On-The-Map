//
//  TabBarController.swift
//  On The Map
//
//  Created by Adam Cmiel on 11/1/15.
//  Copyright © 2015 Adam Cmiel. All rights reserved.
//

import UIKit
import CoreLocation
import SafariServices

protocol Refreshing {
    func refresh(data: [StudentInformationAnnotation])
}

class TabBarController: UITabBarController, SFSafariViewControllerDelegate, CLLocationManagerDelegate, LoginControllerDelegate {
    
    var locationManager: CLLocationManager!
    var locationAuthorized: Bool {
        get {
            let authorizationStatus = CLLocationManager.authorizationStatus()
            switch authorizationStatus {
            case .AuthorizedAlways:
                fallthrough
            case .AuthorizedWhenInUse:
                return true
            default:
                return false
            }
        }
    }
    
    @IBAction func refeshData(sender: AnyObject) {
        StudentDataStore.sharedStore.getStudentLocations { [unowned self] data in
            self.viewControllers?.forEach { vc in
                if vc is Refreshing {
                    let refresher = vc as! Refreshing
                    refresher.refresh(data)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !StudentDataStore.sharedStore.hasUdacitySession {
            navigationController!.performSegueWithIdentifier("showLogin", sender: self)
            let lvc = navigationController?.presentedViewController! as! LoginViewController
            lvc.delegate = self
        }
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        if locationAuthorized {
            locationManager.startUpdatingLocation()
            self.viewControllers?.forEach { vc in
                if vc is MapViewController {
                    let mvc = vc as! MapViewController
                    mvc.mapView.showsUserLocation = true
                }
            }
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
    
    func loginViewController(loginViewController: LoginViewController, didSuccessfullyLoginWithData data: JSONData) {
        loginViewController.dismissViewControllerAnimated(true, completion: nil)
        StudentDataStore.sharedStore.session = data
    }
}
