//
//  User.swift
//  StudioSeshApp
//
//  Created by James B Morris on 8/7/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import Foundation

// This file contains a model of Users: those who utilize the StudioSesh iOS application

class User {
    var email: String? // email address of User
    var profileImageUrl: String? // url to be converted into profile photo
    var username: String? // name of User
    var usernameFromEmail: String? // username of User, parsed from email
    var persona: String? // identity of User, can be "Artist" or "Venue"
    var artforms: String? // arts and/or passions of Users and what they specialize in, nil for venues
    var id: String? // userId of User
    var isFollowing: Bool? // boolean value that indicates whether one User is following another User (used when following Users in Search, Discover, and Profile views)
    var isFollower: Bool?
    var bio: String? // short paragraph describing User to be displayed in Profile view
}

extension User {
    // compile and transform Users and respective data into an array of dictionaries, then return such as a User object (useful for working with and displaying Users in tableViews and collectionViews in other view controllers)
    static func transformUser(dict: [String : Any], key: String) -> User {
        let user = User()
        user.email = dict["email"] as? String
        user.profileImageUrl = dict["profileImageUrl"] as? String
        user.username = dict["username"] as? String
        user.usernameFromEmail = dict["usernameFromEmail"] as? String
        user.persona = dict["persona"] as? String
        if user.persona == "Artist" {
            if let arr = dict["artforms"] as? [String] {
                user.artforms = arr.reduce("", +)
            }else if let dic = dict["artforms"] as? [String:Any] {
                user.artforms = dic["artforms"] as? String
            }
            
        } else {
            user.artforms = ""
        }
        user.id = key
        user.bio = dict["bio"] as? String
        
        return user
    }
}

extension Dictionary where Key == String {}
