//
//  LoginViewController.swift
//  On the Map
//
//  Created by Ian Kennedy on 2/20/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var userName: LoginTextField!
    
    @IBOutlet weak var password: LoginTextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    
    let textFieldDelegate = TextFieldDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        userName.delegate = textFieldDelegate
        password.delegate = textFieldDelegate
//        userName.leftTextMargin = 25
//        password.leftTextMargin = 25
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    @IBAction func loginPressed(sender: AnyObject) {
        

        toggleLoginButton()
        activityIndicator.startAnimating()

        UdacityClient.sharedInstance().loginAndRetrieveUserData(userName.text!, password: password.text!) { (success, error, alert) -> Void in
            
            guard (error == nil) else {
                
                performUIUpdatesOnMain({ () -> Void in
                    self.toggleLoginButton()
                    alert!.addAction(UIAlertAction(title: "OK", style: .Default , handler: nil))
                    self.presentViewController(alert!, animated: true, completion: nil)
                })
                return
            }
            
            guard success else {
                
                print("Login unsuccessful")
                performUIUpdatesOnMain({ () -> Void in
                    self.toggleLoginButton()
                    alert!.addAction(UIAlertAction(title: "OK", style: .Default , handler: nil))
                    self.presentViewController(alert!, animated: true, completion: nil)
                })
                return
            }
            
            performUIUpdatesOnMain({ () -> Void in
                self.toggleLoginButton()
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MapNavigationController") as! UINavigationController
                self.presentViewController(controller, animated: true, completion: nil)
            })
            
        }
        
    }
    
    @IBAction func signupButtonPressed(sender: AnyObject) {
        
        guard let url = NSURL(string: "https://www.udacity.com/account/auth#!/signin") else {
            return
        }
        
        UIApplication.sharedApplication().openURL(url)
    }
    

    func toggleLoginButton() {
        if loginButton.enabled {
            loginButton.enabled = false
            loginButton.alpha = 0.75
            activityIndicator.startAnimating()
        }
        else {
            loginButton.enabled = true
            loginButton.alpha  = 1
            activityIndicator.stopAnimating()
        }
    }
    
}

