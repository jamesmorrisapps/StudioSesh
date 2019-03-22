//
//  Message.swift
//  StudioSeshApp
//
//  Created by James B Morris on 12/23/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

// This file contains a model of Message: direct communication between individuals or groups of artists and/or venues.

class Message {
    
    private var _content: String // protected text content of Message
    
    private var _senderId: String // protected userId of User who sent Message
    
    var content: String { // variable unwrapping protected text content
        return _content
    }
    
    var senderId: String { // variable unwrapping protected userId
        return _senderId
    }
    
    init(content: String, senderId: String) { // initialization function for matching protected content and userIds to respective variables
        self._content = content
        self._senderId = senderId
    }
    
    init(_ dict:[String:String]) { // initialization function to compile and transform Message's respective data into an array of dictionaries, then return such (useful for working with and displaying Messages and their attributes in tableViews)
        self._content = dict["content"]!
        self._senderId = dict["senderId"]!
    }

}
