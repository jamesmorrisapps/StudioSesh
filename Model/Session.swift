//
//  Session.swift
//  StudioSeshApp
//
//  Created by James B Morris on 12/27/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

// This file contains a model of Session: a secured group or "channel" where member Users can exchange Messages.

class Session {
    
    private var _title: String // protected title of Session
    private var _description: String // a protected, short description of Session
    private var _memberCount: Int // protected number of Session members
    private var _members: [String] // protected array of Session member userIds
    private var _key: String // protected Id key of Session object
    
    var title: String { // variable unwrapping protected title
        return _title
    }
    
    var description: String { // variable unwrapping protected description
        return _description
    }
    
    var memberCount: Int { // variable unwrapping protected number of members
        return _memberCount
    }
    
    var members: [String] { // variable unwrapping protected userIds of members
        return _members
    }
    
    var key: String { // variable unwrapping protected Session object Id key
        return _key
    }
    
    init(title: String, description: String, memberCount: Int, members: [String], key: String) { // initialization function for matching protected Session attributes to respective variables
        self._title = title
        self._description = description
        self._memberCount = memberCount
        self._members = members
        self._key = key
    }
    
    
    
}
