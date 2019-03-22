//
//  CommentAPI.swift
//  StudioSeshApp
//
//  Created by James B Morris on 8/10/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

// This file acts as a storage file for all functions with backend functionality relative to Comment objects.

class CommentAPI {
    
    var REF_COMMENTS = Database.database().reference().child("comments") // database address
    
    func observeComments(withPostId id: String, completion: @escaping (Comment) -> Void) { // observe Comment actitivty based on the key of Posts that received the Comment
        REF_COMMENTS.child(id).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String : Any] {
                
                let newComment = Comment.transformComment(dict: dict)
                completion(newComment)
            }
        }
    }
}
