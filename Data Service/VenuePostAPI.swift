//
//  VenuePostAPI.swift
//  StudioSeshApp
//
//  Created by James B Morris on 10/7/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

// This file acts as a storage file for all functions with backend functionality relative to Post objects, specific to just those for a defined Venues object.

class VenuePostAPI {
    
    var REF_VENUE_POSTS = Database.database().reference().child("venuePosts") // database address
    
    
}
