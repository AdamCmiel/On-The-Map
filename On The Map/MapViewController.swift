//
//  MapViewController.swift
//  On The Map
//
//  Created by Adam Cmiel on 11/1/15.
//  Copyright © 2015 Adam Cmiel. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

let MAP_ANNOTATION_IDENTIFIER = "map_pin"

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var store: StudentDataStore {
        get { return StudentDataStore.sharedStore }
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if store.hasUdacitySession {
            store.getStudentLocations { [unowned self] data in
                
                self.mapView.addAnnotations(data)
                print("got student locations")
            }
        }
    }
    
    // MARK: MKMapViewDelegate
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("annotation tapped")
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView: MKAnnotationView? = mapView.dequeueReusableAnnotationViewWithIdentifier(MAP_ANNOTATION_IDENTIFIER)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: MAP_ANNOTATION_IDENTIFIER)
        }
        
        annotationView!.annotation = annotation
        annotationView!.image = UIImage(named: "pin")
        
        return annotationView
    }
    
}
