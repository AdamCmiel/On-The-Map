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

    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func buttonPressed(sender: AnyObject) {
        switch state {
        case .Prompt:
            // forward gecode string
            break
        case .ReadyToSubmit:
            // submit information
            break
        }
    }
    
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
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
