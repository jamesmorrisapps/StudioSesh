//
//  User_BookingAPI.swift
//  StudioSeshApp
//
//  Created by James B Morris on 2/18/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

// This file acts as a storage file for all functions with backend functionality relative to Booking objects, and organizes Booking objects and the venues they are located at for artists.

class User_BookingAPI {
    
    var REF_USER_BOOKINGS = Database.database().reference().child("user-bookings") // database address
    
}
