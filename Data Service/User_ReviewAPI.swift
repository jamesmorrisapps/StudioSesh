//
//  User_ReviewAPI.swift
//  StudioSeshApp
//
//  Created by James B Morris on 2/2/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

// This file acts as a storage file for all functions with backend functionality relative to Reviews objects, specific to just those for a defined User object.

class User_ReviewAPI {
    
    var REF_USER_REVIEWS = Database.database().reference().child("user-reviews") // database address
    
    
    
    // IGNORE:
    //    func observeComments(withPostId id: String, completion: @escaping (Comment) -> Void) {
    //        REF_COMMENTS.child(id).observeSingleEvent(of: .value) { (snapshot) in
    //            if let dict = snapshot.value as? [String : Any] {
    //
    //                let newComment = Comment.transformComment(dict: dict)
    //                completion(newComment)
    //            }
    //        }
    //    }
}
