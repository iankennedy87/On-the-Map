//
//  MapViewDelegate.swift
//  On the Map
//
//  Created by Ian Kennedy on 2/25/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import Foundation
import MapKit
import UIKit
import CoreLocation

class MapViewDelegate: NSObject, MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? StudentLocation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView { // 2
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure)
            }
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView,
        calloutAccessoryControlTapped control: UIControl) {
            let annotation = view.annotation as! StudentLocation
            guard let url = NSURL(string: annotation.link!) else {
                print("String could not be converted to URL")
                return
            }
            
            performUIUpdatesOnMain { () -> Void in
                UIApplication.sharedApplication().openURL(url)
            }
    }
}