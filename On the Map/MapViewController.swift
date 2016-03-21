//
//  MapViewController.swift
//  On the Map
//
//  Created by Ian Kennedy on 2/23/16.
//  Copyright © 2016 Udacity. All rights reserved.
//
import Foundation
import MapKit
import UIKit
import CoreLocation

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let mapViewDelegate = MapViewDelegate()
    
    static let object = UIApplication.sharedApplication().delegate
    let appDelegate = object as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = mapViewDelegate
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshPins:", name: "refresh", object: nil)
        ParseClient.sharedInstance().populateStudentLocationsArray({ (success, error, alert) -> Void in
            
            guard (error == nil) else {
                print("Download failed")
                performUIUpdatesOnMain({ () -> Void in
                    alert!.addAction(UIAlertAction(title: "OK", style: .Default , handler: nil))
                    self.presentViewController(alert!, animated: true, completion: nil)
                })
                return
            }
            
            if success {
                performUIUpdatesOnMain({ () -> Void in
                    self.generateAnnotationsFromStudentLocations()
                })
                
            }
            
        })
        //generateAnnotationsFromStudentLocations()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func generateAnnotationsFromStudentLocations() {
        
        var studentLocations: [StudentInformation] {
            return (UIApplication.sharedApplication().delegate as! AppDelegate).studentInformationArray
        }
        
        for location in studentLocations {
            
            let annotation = StudentLocation(title: location.fullName, link: location.mediaURL, coordinate: location.coordinate)
            appDelegate.mapAnnotations.append(annotation)
            self.mapView.addAnnotations(appDelegate.mapAnnotations)
            
        }

    }
    func refreshPins(notification: NSNotification) {
        performUIUpdatesOnMain { () -> Void in
            
            self.mapView.removeAnnotations(self.appDelegate.temporaryMapAnnotations)
            self.generateAnnotationsFromStudentLocations()
        }
    }
    
}

