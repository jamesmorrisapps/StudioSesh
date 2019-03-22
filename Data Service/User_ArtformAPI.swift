//
//  User_ArtformAPI.swift
//  StudioSeshApp
//
//  Created by James B Morris on 8/25/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

// This file acts as a storage file for all functions with backend functionality relative to Artform objects, specific to just those for a defined User object.

class User_ArtformAPI {

    var REF_USER_ARTFORM = Database.database().reference().child("user-artforms") // database address

}
