//
//  Posts.swift
//  StudioSeshApp
//
//  Created by James B Morris on 8/4/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

// This file contains a model of Posts: photo and video content artists share, or bookings that venues share.

class Posts {
    var caption: String? // artist post description
    var photoUrl: String? // url to be converted into photo
    var uid: String? // userId of person who shared post
    var id: String? // Id key of post object
    var likeCount: Int? // how many likes post has
    var likes: Dictionary<String, Any>? // list of those who have liked post
    var isLiked: Bool? // boolean value for white (empty) or red (full) heart icon on UI
    var perks:String? // venue perks for venue posts
    var description:String? // description (in place of caption) for venue posts
    var price:String? // price to book venue, on venue post
    var ratio: CGFloat? // sizing ratio for shared photos and videos, so shared content is actual size
    var videoUrl: String? // url to be converted into video
    var timestamp: Int? // tracks time post content was shared, for UX and tableView ordering purposes
}

extension Posts {
    // compile and transform Posts and respective data into an array of dictionaries, then return such as a Post object (useful for working with and displaying Posts in tableViews and collectionViews in other view controllers)
    static func transformPostPhoto(dict: [String : Any], key: String) -> Posts {
        let post = Posts()
        post.id = key
        post.caption = dict["caption"] as? String
        post.photoUrl = dict["photoUrl"] as? String
        post.videoUrl = dict["videoUrl"] as? String
        post.uid = dict["uid"] as? String
        post.likeCount = dict["likeCount"] as? Int
        post.likes = dict["likes"] as? Dictionary<String, Any>
        if let currentUserId = Auth.auth().currentUser?.uid {
            if post.likes != nil {
                post.isLiked = post.likes![currentUserId] != nil
            }
        }
        post.ratio = dict["ratio"] as? CGFloat
        post.timestamp = dict["timestamp"] as? Int
        post.price = dict["price"] as? String
        post.description = dict["description"] as? String
        post.perks = dict["perks"] as? String

        return post
    }
    
    
}
