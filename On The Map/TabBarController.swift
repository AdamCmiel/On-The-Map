//
//  TabBarController.swift
//  On The Map
//
//  Created by Adam Cmiel on 11/1/15.
//  Copyright © 2015 Adam Cmiel. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SafariServices

protocol Refreshing {
    func refresh(data: [StudentInformationAnnotation])
}

protocol MapViewControlling {
    var mapView: MKMapView! { get }
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
    
    @IBAction func logout(sender: AnyObject) {
        StudentDataStore.sharedStore = StudentDataStore()
        APIActions.signOut() { [unowned self] _ in
            self.showLoginViewController()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        if !StudentDataStore.sharedStore.hasUdacitySession {
            showLoginViewController()
        }
    }
    
    func showLoginViewController() {
        navigationController!.performSegueWithIdentifier("showLogin", sender: self)
        let lvc = navigationController?.presentedViewController! as! LoginViewController
        lvc.delegate = self
    }
    
    func presentSafariViewController(url: NSURL) {
        if let showUrl = url.sanitize {
            let webView = SFSafariViewController(URL: showUrl)
            webView.delegate = self
            presentViewController(webView, animated: true, completion: nil)
        }
    }
    
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        print("safari view controller finished")
    }
    
    func loginViewController(loginViewController: LoginViewController, didSuccessfullyLoginWithData data: JSONData) {
        loginViewController.dismissViewControllerAnimated(true, completion: nil)
        StudentDataStore.sharedStore.session = data
        
        locationManager.requestWhenInUseAuthorization()
        
        if locationAuthorized {
            locationManager.startUpdatingLocation()
        }
    }
    
    func loginViewController(loginViewController: LoginViewController, didPressSignUpButton: UIButton) {
        let webView = SFSafariViewController(URL: NSURL.signUpURL)
        webView.delegate = self
        loginViewController.presentViewController(webView, animated: true, completion: nil)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.viewControllers?.forEach { vc in
            if vc is MapViewControlling {
                let mvc = vc as! MapViewControlling
                let location = locationManager.location!
                let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
                mvc.mapView.setRegion(region, animated: true)
                mvc.mapView.showsUserLocation = true
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if locationAuthorized {
            locationManager.startUpdatingLocation()
        }
    }
}
