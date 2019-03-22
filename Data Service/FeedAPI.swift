//
//  FeedAPI.swift
//  StudioSeshApp
//
//  Created by James B Morris on 9/6/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

// This file acts as a storage file for all functions with backend functionality relative to Post objects organized by certain attributes with the Home Feed, specific to those for both a defined User object, and defined Venue object.

class FeedAPI {
    
    var REF_FEED = Database.database().reference().child("feed") // database address (feed: arrange Posts)
    
    var REF_VENUEPOST = Database.database().reference().child("venuePosts") // database address (venue bookings)
    
    func observeFeed(withId id: String, completion: @escaping (Posts) -> Void) { // observe new posts added to feed based on their Id key (post.id)
        REF_FEED.child(id).observe(.childAdded) { (snapshot) in
            let key = snapshot.key
            API.Post.observePost(withId: key, completion: { (post) in
                completion(post)
            })
        }
    }
    
    func observeVenuePosts(completion: @escaping ([Posts]) -> Void) { // observe new venue booking posts added to the feed, based on their Id key, and transforms it from a "venuePost" .xib into a Post object to add to feed
        Database.database().reference().child("postedContent").observe(.value) { (posted) in
            guard let posted = posted.value as? [String:Any] else{
                return
            }
            
            self.REF_VENUEPOST.observeSingleEvent(of: .value) { (snapshot) in
                guard let dicts = snapshot.value as? [String : Any] else{
                    return
                }
                var posts = [Posts]()
                for dict in dicts.values {
                    guard let ids = (dict as? [String:Any])?.keys else{
                        continue
                    }
                    for id in ids {
                        for key in posted.keys{
                            if key == id {
                                posts.append(Posts.transformPostPhoto(dict: (posted[key] as! [String:Any]), key: key))
                            }
                        }
                    }
                }
                completion(posts)
            }
            
        }
    }
    
    func observeFeedRemoved(withId id: String, completion: @escaping (Posts) -> Void) { // observe occurrences of Posts removed from feed (such as when User deletes one of their Posts and/or a User unfollowers another User and their respective content)
        REF_FEED.child(id).observe(.childRemoved) { (snapshot) in
            let key = snapshot.key
            API.Post.observePost(withId: key, completion: { (post) in
                completion(post)
            })
        }
    }
    
    
}
