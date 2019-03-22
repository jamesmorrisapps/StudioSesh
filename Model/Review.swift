//
//  Review.swift
//  StudioSeshApp
//
//  Created by James B Morris on 1/3/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import Foundation

// This file contains a model of Reviews: ratings of Users' experiences with other artists and venues.

class Review {
    var reviewText: String? // review content 
    var locationRating: Int? // percentage rating of User location/environment/accessibility
    var arrivalRating: Int? // percentage rating of User arrival/punctuality
    var neatnessRating: Int? // percentage rating of User organization/tidiness
    var qualityRating: Int? // percentage rating of User quality/performance
    var professionalismRating: Int? // percentage rating of User professionalism/composure
    var reviewPercentage: Int? // average percentage rating of a cumulation of the above rating attributes
    var uid: String? // userId of User writing Review
}

extension Review {
    // compile and transform Reviews and respective data into an array of dictionaries, then return such as a Reviews object (useful for working with and displaying Reviews in Reviews view)
    static func transformReview(dict: [String : Any]) -> Review {
        let review = Review()
        review.reviewText = dict["reviewText"] as? String
        review.locationRating = dict["locationRating"] as? Int
        review.arrivalRating = dict["arrivalRating"] as? Int
        review.neatnessRating = dict["neatnessRating"] as? Int
        review.qualityRating = dict["qualityRating"] as? Int
        review.professionalismRating = dict["professionalismRating"] as? Int
        review.reviewPercentage = dict["reviewPercentage"] as? Int
        review.uid = dict["uid"] as? String
        return review
    }
}
