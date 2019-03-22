//
//  UserAPI.swift
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

// This file acts as a storage file for all functions with backend functionality relative to User objects.

class UserAPI {
    
    var REF_USERS = Database.database().reference().child("users") // database address
    
    var CURRENT_USER = Auth.auth().currentUser // classification of app's current user
    
    func observeUsersByUsername(username: String, completion: @escaping (String) -> Void) { // observe User activity based on their physical username (from User model)
        
        REF_USERS.observeSingleEvent(of: .value) { (snapshot) in
            guard let arr = snapshot.value as? [String:Any] else{
                return
            }
            for key in arr.keys {
                if let dict = arr[key] as? [String:Any], let name = dict["usernameFromEmail"] as? String,name.contains(username.replacingOccurrences(of: "_", with: " ")) {
                    completion(key)
                    break
                }
            }
        }
        // IGNORE:
//        REF_USERS.queryOrdered(byChild: "username_lowercased").queryEqual(toValue: username).observe(.childAdded) { (snapshot) in
//            print(snapshot.value)
//            if let dict = snapshot.value as? [String : Any] {
//                let user = User.transformUser(dict: dict, key: snapshot.key)
//                completion(user)
//            }
//        }
    }
    
    func observeUsers(withId uid: String, completion: @escaping (User) -> Void) { // observe User activity based on their userId
        REF_USERS.child(uid).observeSingleEvent(of: .value, with: { snapshot in
            if let dict = snapshot.value as? [String : Any] {
                let user = User.transformUser(dict: dict, key: snapshot.key)
                completion(user)
            }else{
               print(snapshot.exists(),snapshot.hasChildren())
            }
        })
    }
    
    func observeCurrentUser(completion: @escaping (User) -> Void) { // observe and identify who app's current User is, and get userId + User object (model)
        guard let currentUser = Auth.auth().currentUser else {
            assert(false, "current user is nil")
            return
        }
        REF_USERS.child(currentUser.uid).observeSingleEvent(of: .value, with: { snapshot in
            if let dict = snapshot.value as? [String : Any] {
                let user = User.transformUser(dict: dict, key: snapshot.key)
                if user.id! == API.User.CURRENT_USER?.uid {
                    completion(user)
                }else{
                    assert(false, "user id is nil")
                }
            }else{
                assert(false, "snapshot is not a dictionary")
                //completion(nil)
            }
        })
    }
    
    func queryUser(withText text: String, completion: @escaping (User) -> Void) { // query existing Users by their modified lowercase username (i.e. user.username.lowercased()), return physical User object
        REF_USERS.queryOrdered(byChild: "username_lowercase").queryStarting(atValue: text).queryEnding(atValue: text + "\u{f8ff}").queryLimited(toFirst: 10).observeSingleEvent(of: .value) { (snapshot) in
            snapshot.children.forEach({ (s) in
                let child = s as! DataSnapshot
                if let dict = child.value as? [String : Any] {
                    let user = User.transformUser(dict: dict, key: child.key)
                    completion(user)
                }
            })
        }
    }
    
    func queryUserByPersona(withPersona persona: String, completion: @escaping (User) -> Void) {
        REF_USERS.queryOrdered(byChild: "persona").queryStarting(atValue: persona).queryEnding(atValue: persona + "\u{f8ff}").queryLimited(toFirst: 10).observeSingleEvent(of: .value) { (snapshot) in
            snapshot.children.forEach({ (s) in
                let child = s as! DataSnapshot
                if let dict = child.value as? [String : Any] {
                    let user = User.transformUser(dict: dict, key: child.key)
                    completion(user)
                }
            })
        }
    }
    
    func queryUserText(withText text: String, completion: @escaping ([String]) -> ()) { // query existing Users by their modified lowercase username (i.e. user.username.lowercased()), return array of existing User usernames
        REF_USERS.queryOrdered(byChild: "username_lowercase").queryStarting(atValue: text).queryEnding(atValue: text + "\u{f8ff}").queryLimited(toFirst: 10).observeSingleEvent(of: .value) { (snapshot) in
            snapshot.children.forEach({ (s) in
                let child = s as! DataSnapshot
                if let dict = child.value as? [String : Any] {
                    let user = User.transformUser(dict: dict, key: child.key)
                    completion([user.username!])
                }
            })
        }
    }
    
    var REF_CURRENT_USER: DatabaseReference? { // database classification of app's current user
        guard let currentUser = Auth.auth().currentUser else {
            return nil
        }
        
        return REF_USERS.child(currentUser.uid)
    }
}

