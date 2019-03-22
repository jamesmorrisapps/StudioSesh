//
//  PostAPI.swift
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

class PostAPI {
    
    // This file acts as a storage file for all functions with backend functionality relative to Post objects.
    
    var REF_POSTS = Database.database().reference().child("postedContent") // database address
    
    func observePosts(completion: @escaping (Posts) -> Void) { // observe general Post activity
        REF_POSTS.observe(.childAdded) { (snapshot: DataSnapshot) in
            if let dict = snapshot.value as? [String : Any] {
                
                let newPost = Posts.transformPostPhoto(dict: dict, key: snapshot.key)
                completion(newPost)
            }
        }
    }
    
    func observePost(withId id: String, completion: @escaping (Posts) -> Void) { // observe Post activity relative to the User who posted it
        REF_POSTS.child(id).observeSingleEvent(of: .value) { (snapshotNewUserPost) in
            print(snapshotNewUserPost.value!)
            if let dict = snapshotNewUserPost.value as? [String : Any] {
                let post = Posts.transformPostPhoto(dict: dict, key: snapshotNewUserPost.key)
                completion(post)
            }
        }
    }
    
    func observeLikes(withId id: String, completion: @escaping (User) -> Void) { // observe Likes activity relative to the User who likes a post
        REF_POSTS.child(id).child("likes").observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String : Any] {
                let user = User.transformUser(dict: dict, key: snapshot.key)
                completion(user)
            }
        }
    }
    
    func observeTopPosts(completion: @escaping (Posts) -> Void) { // observe, track, and display most popular posts based on number of Likes
        REF_POSTS.queryOrdered(byChild: "likeCount").observeSingleEvent(of: .value) { (snapshot) in
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot]).reversed()
            arraySnapshot.forEach({ (child) in
                if let dict = child.value as? [String : Any] {
                    let post = Posts.transformPostPhoto(dict: dict, key: child.key)
                    completion(post)
                }
            })
        }
    }
    
}
