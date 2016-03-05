//
//  TextFieldDelegate.swift
//  On the Map
//
//  Created by Ian Kennedy on 2/27/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import Foundation
import UIKit

class TextFieldDelegate: NSObject, UITextFieldDelegate {
    
    var textIsDefault: Bool = true
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
        textField.autocorrectionType = UITextAutocorrectionType.No
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true
    }
    
}