//
//  Notification.swift
//  StudioSeshApp
//
//  Created by James B Morris on 12/4/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

// This file contains a model of Notifications: alerts to a User's followers when said User engages in a sort of activitiy with another User and/or their content within the app (i.e. likes, comments, messages, bookings, followings, etc.).

class Notification {
    var from: String? // userId of User who initiates notification
    var objectId: String? // userId of User who is the recipient of the notification
    var type: String? // type of notification (based on said activity types)
    var timestamp: Int? // tracks time activity occurred, for UX and notification ordering purposes
    var id: String? // Id of Notification object
}

extension Notification {
    // compile and transform Notification and respective data into an array of dictionaries, then return such as a Notification object (useful for working with and displaying Notifications in tableViews)
    static func transformNotification(dict: [String : Any], key: String) -> Notification {
        let notification = Notification()
        notification.from = dict["from"] as? String
        notification.objectId = dict["objectId"] as? String
        notification.type = dict["type"] as? String
        notification.timestamp = dict["timestamp"] as? Int
        notification.id = key
        
        return notification
    }
}
