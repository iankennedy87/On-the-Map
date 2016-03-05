//
//  GCDBlackBox.swift
//  On the Map
//
//  Created by Ian Kennedy on 2/26/16.
//  Copyright © 2016 Udacity. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}