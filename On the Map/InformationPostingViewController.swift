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
        
        activityIndicator.hidesWhenStopped = true
        setButtons([findButton, submitButton])
        
        locationTextField.delegate = textFieldDelegate
        urlTextField.delegate = textFieldDelegate
        
        
    }
    
    @IBAction func findButtonPressed(sender: AnyObject) {

        toggleButton(findButton)
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(locationTextField.text!) { (placemarks, error) -> Void in

            guard (error == nil) else {
                
                performUIUpdatesOnMain({ () -> Void in
                    self.toggleButton(self.findButton)
                    let alert = UIAlertController(title: nil, message: "Geocoding of address failed", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    print("error geocoding address")
                })

                return
            }
            
            guard let placemark = placemarks![0] as CLPlacemark? else {
                print("No placemarks found")
                return
            }
            
            performUIUpdatesOnMain({ () -> Void in
                self.toggleButton(self.findButton)
            })
            
            performUIUpdatesOnMain({ () -> Void in

                
                let coordinate = placemark.location?.coordinate
                self.coordinate = coordinate
                
                let annotation = MKPlacemark(coordinate: coordinate!, addressDictionary: nil)
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
        view.bringSubviewToFront(activityIndicator)
        toggleButton(submitButton)

        var jsonParameters = UdacityClient.sharedInstance().jsonParameters
        jsonParameters[ParseClient.JSONBodyKeys.MapString] = locationTextField.text!
        jsonParameters[ParseClient.JSONBodyKeys.MediaURL] = urlTextField.text!
        jsonParameters[ParseClient.JSONBodyKeys.Latitude] = coordinate!.latitude
        jsonParameters[ParseClient.JSONBodyKeys.Longitude] = coordinate!.longitude
        
        ParseClient.sharedInstance().postStudentLocation(jsonParameters) { (results, error, alert) -> Void in
            guard (error == nil) else {
                performUIUpdatesOnMain({ () -> Void in
                    alert!.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alert!, animated: true, completion: nil)
                    self.toggleButton(self.submitButton)
                })
                return
            }
            performUIUpdatesOnMain({ () -> Void in
                self.toggleButton(self.submitButton)
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        }
        
    }

    func setButtons(buttons: [UIButton]) {
        for button in buttons {
            button.layer.cornerRadius = 10
            button.clipsToBounds = true
        }
    }
    
    func toggleButton(button: UIButton) {
        if button.enabled {
            button.enabled = false
            button.alpha = 0.75
            activityIndicator.startAnimating()
        }
        else {
            button.enabled = true
            button.alpha  = 1
            activityIndicator.stopAnimating()
        }
    }

}