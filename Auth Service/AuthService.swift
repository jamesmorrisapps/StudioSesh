//
//  AuthService.swift
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

// This file acts as a storage file for all functions with backend functionality relative to User Authentication, including Sign In, Sign Up, Update User Data, and Log Out.

class AuthService {

    static func signIn(email: String, password: String, onSuccess: @escaping () -> Void, onError: @escaping () -> Void) { // authenticate and sign in User into app
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if (error != nil) {
                onError()
            } else {
                onSuccess()
            }
        }
    }
    
    static func signUp(username: String, usernameFromEmail: String, email: String, password: String, persona: String, bio: String, imageData: Data, onSuccess: @escaping () -> Void, onError: @escaping () -> Void) { // authenticate and sign up User for app
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if (error != nil) {
                onError()
            } else {
                let uid = Auth.auth().currentUser!.uid
                
                let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("profileImage").child(uid)
                
                    storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                        guard metadata != nil else {
                            print("Error occurred.")
                            return
                        }
                        storageRef.downloadURL { (url, error) in
                            guard (url) != nil else {
                                print("Error occurred.")
                                return
                            }
                            self.updateUserInformation(url: url!.absoluteString, username: username, usernameFromEmail: usernameFromEmail, email: email, persona: persona, bio: bio, uid: uid, onSuccess: onSuccess)
                        }
                    })
                }
            }
        }
    
    static func updateUserInformation(url: String, username: String, usernameFromEmail: String, email: String, persona: String, bio: String, uid: String, onSuccess: @escaping () -> Void) { // update key User information such as username, email, artforms, bio, and profile image, with User inputs
        let ref = Database.database().reference()
        let usersReference = ref.child("users")
        let newReference = usersReference.child(uid)
        newReference.setValue(["username" : username, "username_lowercase" : username.lowercased().trimmingCharacters(in: .whitespacesAndNewlines), "usernameFromEmail" : usernameFromEmail, "email" : email, "persona" : persona, "artforms" : [""], "bio" : bio, "profileImageUrl" : url])
        onSuccess()
    }
    
    // IGNORE:
//    static func updateData(url: String, username: String, email: String, bio: String, uid: String, onSuccess: @escaping () -> Void) {
//        let ref = Database.database().reference()
//        let usersReference = ref.child("users")
//        let newReference = usersReference.child(uid)
//        newReference.setValue(["username" : username, "username_lowercase" : username.lowercased(), "email" : email, "bio" : bio, "profileImageUrl" : url])
//        onSuccess()
//    }
    
    static func updateUserInfo(username: String, email: String, bio: String, imageData: Data, onSuccess: @escaping () -> Void, onError: @escaping () -> Void) { // update key User information such as username, email, artforms, bio, and profile image
        
        API.User.CURRENT_USER?.updateEmail(to: email, completion: { (error) in
            if error != nil {
                onError()
                print("Error: \(String(describing: error?.localizedDescription))")
            } else {
                let uid = API.User.CURRENT_USER?.uid
                
                let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("profileImage").child(uid!)
                
                storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                    guard metadata != nil else {
                        print("Error occurred.")
                        return
                    } // function above and function below take chosen image data and transform to url and pushes url to storage on database
                    storageRef.downloadURL { (url, error) in
                        guard (url) != nil else {
                            print("Error occurred.")
                            return
                        }
                        
                        let profileImageUrl = metadata?.downloadURL()?.absoluteString
                        
                        self.updateDatabase(url: profileImageUrl!, username: username, email: email, bio: bio, onSuccess: onSuccess, onError: onError)
                        
                    }
                })
            }
        })
    }
    
    static func updateDatabase(url: String, username: String, email: String, bio: String, onSuccess: @escaping () -> Void, onError: @escaping () -> Void) { // update key User information such as username, email, artforms, bio, and profile image, on database
        
        let dict = ["username" : username, "email" : email, "bio" : bio, "profileImageUrl" : url]
        
        API.User.REF_CURRENT_USER?.updateChildValues(dict, withCompletionBlock: { (error, ref) in
            if error != nil {
                onError()
                print("Error: \(String(describing: error?.localizedDescription))")
            } else {
                onSuccess()
                print("Success!")
            }
        })
    }
    
    static func logout(onSuccess: @escaping () -> Void, onError: @escaping () -> Void) { // authenticate and log out User from app
        
        do {
            try Auth.auth().signOut()
            onSuccess()
            
        } catch let logoutError {
            print(logoutError.localizedDescription)
        }
    }
    
    
}
    
    

