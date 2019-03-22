//
//  FollowAPI.swift
//  StudioSeshApp
//
//  Created by James B Morris on 9/4/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

// This file acts as a storage file for all functions with backend functionality relative to Users following and unfollowing one another.

class FollowAPI {
    
    var REF_FOLLOWERS = Database.database().reference().child("followers") // database address (follower Users)
    
    var REF_FOLLOWING = Database.database().reference().child("following") // database address (following Users)
    
    func followAction(withUser id: String) { // follow another User, specified by userId
        
        API.UserPosts.REF_USER_POSTS.child(id).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String : Any] {
                for key in dict.keys {
                    Database.database().reference().child("feed").child(API.User.CURRENT_USER!.uid).child(key).setValue(true)
                }
            }
        }
        
        REF_FOLLOWERS.child(id).child(API.User.CURRENT_USER!.uid).setValue(true)
        
        REF_FOLLOWING.child(API.User.CURRENT_USER!.uid).child(id).setValue(true)
    }
    
    func observeFollows(withId id: String, completion: @escaping (User) -> Void) { // observe Following activity according to Users specified by their userId
        REF_FOLLOWERS.child(id).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String : Any] {
                let user = User.transformUser(dict: dict, key: snapshot.key)
                completion(user)
            }
        }
    }
    
    func unfollowAction(withUser id: String) { // unfollow another User, specified by userId
        
        API.UserPosts.REF_USER_POSTS.child(id).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String : Any] {
                for key in dict.keys {
                    Database.database().reference().child("feed").child(API.User.CURRENT_USER!.uid).child(key).removeValue()
                }
            }
        }
        
        REF_FOLLOWERS.child(id).child(API.User.CURRENT_USER!.uid).setValue(NSNull())
        
        REF_FOLLOWING.child(API.User.CURRENT_USER!.uid).child(id).setValue(NSNull())
    }
    
    func isFollowing(userId: String, completed: @escaping (Bool) -> Void) { // check if one User is following another User, specified by their userId
        REF_FOLLOWERS.child(userId).child(API.User.CURRENT_USER!.uid).observeSingleEvent(of: .value) { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                completed(false)
            } else {
                completed(true)
            }
        }
    }
    
    func isFollower(userId: String, completed: @escaping (Bool) -> Void) { // check if one User is a follower of another User, specified by their userId
        REF_FOLLOWING.child(userId).child(API.User.CURRENT_USER!.uid).observeSingleEvent(of: .value) { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                completed(false)
            } else {
                completed(true)
            }
        }
    }
    
    func fetchFollowingCount(userId: String, completion: @escaping (Int) -> Void) { // get a User's number of Users they are following, based on their userId
        REF_FOLLOWING.child(userId).observe(.value) { (snapshot) in
            let count = Int(snapshot.childrenCount)
            completion(count)
        }
    }
    
    func fetchFollowersCount(userId: String, completion: @escaping (Int) -> Void) { // get a User's number of followers, based on their userId
        REF_FOLLOWERS.child(userId).observe(.value) { (snapshot) in
            let count = Int(snapshot.childrenCount)
            completion(count)
        }
    }
    
    
}
