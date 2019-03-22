//
//  Artform.swift
//  StudioSeshApp
//
//  Created by James B Morris on 8/17/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import Foundation

// This file contains a model of Artforms: arts and/or passions of Users and what they specialize in, nil for venues
// IMPORTANT: this is already instantiated within the User model, therefore this class is predominantly unused. However, this class can be utilized in the future for querying Users based on Artform instead of username

class Artform {
    var artforms: String? // arts and/or passions of Users and what they specialize in, nil for venues
    var uid: String? // userId of Users with artforms
}

extension Artform {
    // compile and transform Artforms and respective data into an array of dictionaries, then return such as a Artform object (useful for working with and displaying Artforms in tableViews and collectionViews)
    static func transformArtform(dict: [String : Any]) -> Artform {
        let artform = Artform()
        artform.artforms = dict["artforms"] as? String
        artform.uid = dict["uid"] as? String
        return artform
    }
}
