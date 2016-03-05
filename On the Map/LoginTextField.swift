//
//  LoginTextField.swift
//  On the Map
//
//  Created by Ian Kennedy on 2/28/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import Foundation
import UIKit


class LoginTextField : UITextField {
    var leftTextMargin : CGFloat = 0.0
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        var newBounds = bounds
        newBounds.origin.x += leftTextMargin
        return newBounds
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        var newBounds = bounds
        newBounds.origin.x += leftTextMargin
        return newBounds
    }
}

