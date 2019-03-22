//
//  UserPostAPI.swift
//  StudioSeshApp
//
//  Created by James B Morris on 8/16/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

// This file acts as a storage file for all functions with backend functionality relative to Post objects, specific to just those for a defined User object.

class UserPostAPI {
    
    var REF_USER_POSTS = Database.database().reference().child("userPosts") // database address
    
    func fetchUserPosts(userId: String, completion: @escaping (String) -> Void) { // get Post objects for a defined User object, specified with User's userId
        REF_USER_POSTS.child(userId).observe(.childAdded) { (snapshot) in
            completion(snapshot.key)
        }
    }
    
    func fetchUserPostsCount(userId: String, completion: @escaping (Int) -> Void) { // get number of Post objects for a defined User object, specified with User's userId
        REF_USER_POSTS.child(userId).observe(.value) { (snapshot) in
            let count = Int(snapshot.childrenCount)
            completion(count)
        }
    }
}

