//
//  NotificationsAPI.swift
//  StudioSeshApp
//
//  Created by James B Morris on 11/30/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

// This file acts as a storage file for all functions with backend functionality relative to Notification objects.

class NotificationsAPI {
    
    var REF_NOTIFICATIONS = Database.database().reference().child("notifications") // database address
    
    func observeNotifications(withId id: String, completion: @escaping (Notification) -> Void) { // observe Notification activity based on their Id key
        REF_NOTIFICATIONS.child(id).observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? [String : Any] {
                let newNotif = Notification.transformNotification(dict: dict, key: snapshot.key)
                completion(newNotif)
            }
            
        }
    }
    
}
