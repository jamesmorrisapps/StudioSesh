//
//  ReviewAPI.swift
//  StudioSeshApp
//
//  Created by James B Morris on 1/3/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

// This file acts as a storage file for all functions with backend functionality relative to Review objects.

class ReviewAPI {
    
    var REF_REVIEWS = Database.database().reference().child("reviews") // database address
    
    func observeReviews(withUserId id: String, completion: @escaping (Review) -> Void) { // observe Reviews activity specified by userId of User who wrote Review
        REF_REVIEWS.child(id).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String : Any] {
                
                let newReview = Review.transformReview(dict: dict)
                completion(newReview)
            }
        }
    }
}
