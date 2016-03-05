//
//  InformationPostingView.swift
//  On the Map
//
//  Created by Ian Kennedy on 2/27/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import Foundation

import UIKit
import MapKit




class InformationPostingViewController: UIViewController {
    
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let mapViewDelegate = MapViewDelegate()
    var mapLocations = [CLPlacemark]()
    var coordinate: CLLocationCoordinate2D?
    
    let textFieldDelegate = TextFieldDelegate()
    let customBlueColor = UIColor(red: 26.0/255, green: 119.0/255, blue: 172.0/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        view.bringSubviewToFront(cancelButton)
//        view.bringSubviewToFront(toolbar)
//        cancelButton.tintColor = customBlueColor
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.hidden = true
        setButtons([findButton, submitButton])
        
        locationTextField.delegate = textFieldDelegate
        urlTextField.delegate = textFieldDelegate
        
        urlTextField.textAlignment = NSTextAlignment.Center
        locationTextField.textAlignment = NSTextAlignment.Center
        
    }
    
    @IBAction func findButtonPressed(sender: AnyObject) {
        //        print("Location text field: \(locationTextField.text!)")
        

        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(locationTextField.text!) { (placemarks, error) -> Void in
            self.activityIndicator.startAnimating()
            guard (error == nil) else {
                
                performUIUpdatesOnMain({ () -> Void in
                    let alert = UIAlertController(title: nil, message: "Geocoding of address failed", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    self.activityIndicator.stopAnimating()
                    print("error geocoding address")
                })

                return
            }
            
            //            print("Placemark: \(placemarks)")
            
            guard let placemark = placemarks![0] as CLPlacemark? else {
                print("No placemarks found")
                return
            }
            performUIUpdatesOnMain({ () -> Void in
                self.activityIndicator.stopAnimating()
                
                let coordinate = placemark.location?.coordinate
                self.coordinate = coordinate
                
                let annotation = MKPlacemark(coordinate: coordinate!, addressDictionary: nil)
                //            print("Annotation: \(annotation)")
                self.mapView.addAnnotation(annotation)
                
                self.mapView.centerCoordinate = coordinate!
                let span = MKCoordinateSpanMake(0.1,0.1)
                let region = MKCoordinateRegionMake(coordinate!, span)
                self.mapView.region = region
                
                self.submitButton.hidden = false
                self.mapView.hidden = false
                self.urlTextField.hidden = false
                
                self.cancelButton.tintColor = UIColor.whiteColor()
                
                self.view.bringSubviewToFront(self.urlTextField)
                self.view.bringSubviewToFront(self.submitButton)
                self.view.bringSubviewToFront(self.cancelButton)
                
                
                
                self.view.backgroundColor = self.customBlueColor
                
                self.mapView.setRegion(region, animated: true)
            })
            
            
            
            
        }
        
        
    }
    @IBAction func cancel(sender: UIButton) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func submitButtonPressed(sender: UIButton) {
        
        var jsonParameters = UdacityClient.sharedInstance().jsonParameters
        jsonParameters[ParseClient.JSONBodyKeys.MapString] = locationTextField.text!
        jsonParameters[ParseClient.JSONBodyKeys.MediaURL] = urlTextField.text!
        jsonParameters[ParseClient.JSONBodyKeys.Latitude] = coordinate!.latitude
        jsonParameters[ParseClient.JSONBodyKeys.Longitude] = coordinate!.longitude
        
        ParseClient.sharedInstance().postStudentLocation(jsonParameters) { (results, error, alert) -> Void in
            guard (error == nil) else {
                print("post student location failed")
                return
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }

    func setButtons(buttons: [UIButton]) {
        for button in buttons {
            
            button.layer.cornerRadius = 10
            button.clipsToBounds = true
        }
    }
}