//
//  ArtformsAPI.swift
//  StudioSeshApp
//
//  Created by James B Morris on 8/17/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

// This file acts as a storage file for all functions with backend functionality relative to Artform objects.

class ArtformsAPI {
    
    var REF_ARTFORMS = Database.database().reference().child("artforms") // database address
    
    func observeArtforms(withArtformId id: String, completion: @escaping (Artform) -> Void) { // observe Artform activity based on the userId of the User with such Artform(s)
        REF_ARTFORMS.child(id).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String : Any] {
                
                let newArtform = Artform.transformArtform(dict: dict)
                completion(newArtform)
            }
        }
    }
    
}
