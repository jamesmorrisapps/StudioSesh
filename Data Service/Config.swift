//
//  Config.swift
//  StudioSeshApp
//
//  Created by James B Morris on 7/31/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

// This file instantiates a direct backend url to connect StudioSesh to the backend database/server (Google Firebase).

struct Config {
    static var STORAGE_ROOT_REF = "gs://studiosesh-ecd23.appspot.com"
}
