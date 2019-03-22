//
//  Venue_BookingAPI.swift
//  StudioSeshApp
//
//  Created by James B Morris on 2/15/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

// This file acts as a storage file for all functions with backend functionality relative to Booking objects, and organizes Booking objects and the artists that booked them for venues.

class Venue_BookingAPI {
    
    var REF_VENUE_BOOKINGS = Database.database().reference().child("venue-bookings") // database address
    
}
