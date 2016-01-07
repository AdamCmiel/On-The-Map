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

typealias VoidCallback = () -> ()

class InformationViewController: UIViewController, MapViewControlling, UITextFieldDelegate {
    
    private enum State {
        case LocationPrompt
        case URLPrompt
        case ReadyToSubmit
    }
    
    private var state: State = .LocationPrompt
    private var location: CLLocation?
    private var url: String = "https://www.udacity.com"

    @IBAction final func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction final func buttonPressed(sender: AnyObject) {
        switch state {
        case .LocationPrompt:
            let queryString = locationField.text!
            promptLabel.text = "Searching for the location"
            disable()
            
            CLGeocoder().geocodeAddressString(queryString) { [unowned self] placemark, error in
                guard error == nil else {
                    return self.geocodeAlert(.Error, then: {
                        self.enable()
                    })
                }
                
                guard placemark!.count > 0 else {
                    return self.geocodeAlert(.NoMatches, then: {
                        self.enable()
                    })
                }
                
                let pm = placemark![0]
                let location = pm.location!
                self.location = location
                let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
                self.mapView.setRegion(region, animated: true)
                self.setButtonTitle("Add URL")
                self.promptLabel.text = "Add a url to your post"
                self.locationField.text = nil
                self.locationField.placeholder = self.url
                self.locationField.returnKeyType = .Send
                self.locationField.keyboardType = .URL
                self.state = .URLPrompt
                self.enable()
            }
        case .URLPrompt:
            url = locationField.text!
            setButtonTitle("Submit")
            promptLabel.text = "Submit Data"
            state = .ReadyToSubmit
            
        case .ReadyToSubmit:
            sendInformationData()
        }
    }
    
    final private func enable() {
        locationField.enabled = true
        locationField.hidden = false
        findButton.enabled = true
        activityIndicator.hidden = true
        if activityIndicator.isAnimating() {
            activityIndicator.stopAnimating()
        }
    }
    
    final private func disable() {
        locationField.enabled = false
        locationField.hidden = true
        findButton.enabled = false
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
    
    private enum GeocodeAlertFailure {
        case Error
        case NoMatches
    }
    
    final private func geocodeAlert(failure: GeocodeAlertFailure, then completion: VoidCallback) {
        var message: String
        
        switch failure {
        case .Error:
            message = "There was an error geocoding the location"
        case .NoMatches:
            message = "Could not find location on map, try again?"
        }
        
        let alert = UIAlertController(title: "Geocode Failed", message: message, preferredStyle: .Alert)
        let okButton = UIAlertAction(title: "Dang, Try Again", style: .Default) { _ in
            alert.dismissViewControllerAnimated(true, completion: nil)
            completion()
        }
        alert.addAction(okButton)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private enum PostAlertType {
        case Success
        case Failure
    }
    
    final private func postAlert(result: PostAlertType, then completion: VoidCallback) {
        var message: String
        var title: String
        var buttonTitle: String
        
        switch result {
        case .Success:
            title = "Hooray!"
            message = "Data saved successfully"
            buttonTitle = "Okay"
        case .Failure:
            title = "Post Failed"
            message = "Could not post message to server"
            buttonTitle = "Sorry"
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okButton = UIAlertAction(title: buttonTitle, style: .Default) { _ in
            alert.dismissViewControllerAnimated(true, completion: nil)
            completion()
        }
        alert.addAction(okButton)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    final private func setButtonTitle(title: String) {
        findButton.setTitle(title, forState: .Normal)
        findButton.setTitle(title, forState: .Selected)
    }
    
    final private func sendInformationData() {
        
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
        
        disable()
        promptLabel.text = "Sending Data to Server"
        
        APIActions.postStudentLocation(data) { [unowned self] result in
            switch result {
            case .Success:
                self.postAlert(.Success, then: {
                    self.cancel(self)
                })
            case .Failure(let error):
                print("POST location error")
                print(error)
                
                self.postAlert(.Failure, then: {
                    self.cancel(self)
                })
            }
        }
    }
    
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    final override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        findButton.titleLabel?.numberOfLines = 0
        findButton.titleLabel?.adjustsFontSizeToFitWidth = true
        findButton.titleLabel?.lineBreakMode = .ByClipping
        
        locationField.returnKeyType = .Search
        locationField.delegate = self
    }
    
    final func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch state {
        case .LocationPrompt:
            buttonPressed(self)
        case .URLPrompt:
            sendInformationData()
        default:
            cancel(self)
        }
        
        return true
    }
}
