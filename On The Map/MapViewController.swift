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

class MapViewController: TabViewController, MKMapViewDelegate, Refreshing, MapViewControlling {
    
    @IBOutlet weak var mapView: MKMapView!
    
    private var mapViewsCurrentAnnotations: [MKAnnotation] = []
    
    // MARK: MKMapViewDelegate
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("annotation tapped")
        
        let tap = UITapGestureRecognizer(target: self, action: "annotationWasTapped:")
        view.addGestureRecognizer(tap)
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView: MKAnnotationView? = mapView.dequeueReusableAnnotationViewWithIdentifier(MAP_ANNOTATION_IDENTIFIER)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: MAP_ANNOTATION_IDENTIFIER)
        }
        
        annotationView!.annotation = annotation
        annotationView!.canShowCallout = true
        annotationView!.image = UIImage(named: "pin")
        
        return annotationView
    }
    
    // MARK: Gestures
    
    func annotationWasTapped(recognizer: UIGestureRecognizer) {
        let view: MKAnnotationView = recognizer.view as! MKAnnotationView
        let annotation = view.annotation as! StudentInformationAnnotation
        
        if let urlPath = annotation.subtitle {
            if let url = NSURL(string: urlPath) {
                let tbController = tabBarController as! TabBarController
                tbController.presentSafariViewController(url)
            }
        } else {
            print("no media url")
            
        }
    }
    
    // MARK: - Refreshing
    
    func refresh(data: [StudentInformationAnnotation]) {
        mapView.removeAnnotations(mapViewsCurrentAnnotations)
        mapView.addAnnotations(data)
        mapViewsCurrentAnnotations = data
        print("got student locations")
    }
}
