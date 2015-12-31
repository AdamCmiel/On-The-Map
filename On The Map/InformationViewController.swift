//
//  InformationViewController.swift
//  On The Map
//
//  Created by Adam Cmiel on 11/1/15.
//  Copyright © 2015 Adam Cmiel. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class InformationViewController: UIViewController, MapViewControlling {
    
    enum State {
        case Prompt
        case ReadyToSubmit
    }
    
    var state: State = .Prompt
    var location: CLLocation?

    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func buttonPressed(sender: AnyObject) {
        switch state {
        case .Prompt:
            
            let queryString = locationField.text!
            CLGeocoder().geocodeAddressString(queryString) { [unowned self] placemark, error in
                guard error == nil else {
                    return self.cancel(self)
                }
                
                guard placemark!.count > 0 else {
                    return self.cancel(self)
                }
                
                let pm = placemark![0]
                self.makeReady(pm.location!)
            }
            
            // forward gecode string
            break
        case .ReadyToSubmit:
            // submit information
            
            sendInformationData()
            break
        }
    }
    
    func makeReady(location: CLLocation) {
        self.location = location
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        mapView.setRegion(region, animated: true)
        findButton.setTitle("Submit", forState: .Normal)
        findButton.setTitle("Submit", forState: .Selected)
        state = .ReadyToSubmit
    }
    
    func sendInformationData() {
        
        let store = StudentDataStore.sharedStore
        var data: [String: AnyObject] = [:]
        
        if let val = store.udacityKey {
            data["uniqueKey"] = val
        }
        
        if let val = store.firstName {
            data["firstName"] = val
        }
        
        if let val = store.lastName {
            data["lastName"] = val
        }
        
        if let val = location?.coordinate.latitude {
            data["latitude"] = val
        }
        
        if let val = location?.coordinate.longitude {
            data["longitude"] = val
        }
        
        if let val = locationField.text {
            data["mapString"] = val
        }
        
        data["mediaURL"] = "https://udacity.com"
        
        APIActions.postStudentLocation(data) { [unowned self] result in
            switch result {
            case .Success:
                return self.cancel(self)
            case .Failure(let error):
                print("POST location error")
                print(error)
                return self.cancel(self)
            }
        }
    }
    
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        findButton.titleLabel?.numberOfLines = 0
        findButton.titleLabel?.adjustsFontSizeToFitWidth = true
        findButton.titleLabel?.lineBreakMode = .ByClipping
        
        let pvc = presentingViewController as! UINavigationController
        pvc.viewControllers.forEach { vc in
            if vc is TabBarController {
                let tbc = vc as! TabBarController
                if tbc.locationAuthorized {
                    let location = tbc.locationManager.location!
                    let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
                    mapView.setRegion(region, animated: true)
                }
            }
        }
    }
}
