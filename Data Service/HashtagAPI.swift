//
//  HashtagAPI.swift
//  StudioSeshApp
//
//  Created by James B Morris on 11/26/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

// This file acts as a storage file for all functions with backend functionality relative to handling Hashtags, a "#" followed by text to define trending keywords, that are clickable and searchable.

class HashtagAPI {
    
    var REF_HASHTAGS = Database.database().reference().child("hashtags") // database address
    
    func fetchPosts(withTag tag: String, completion: @escaping(String) -> Void) { // find and displays Posts, specified by found hashtags in the description of the post
        REF_HASHTAGS.child(tag.lowercased()).observe(.childAdded) { (snapshot) in
            completion(snapshot.key)
        }
    }
    
}
