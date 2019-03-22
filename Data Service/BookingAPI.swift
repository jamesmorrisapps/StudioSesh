//
//  BookingAPI.swift
//  StudioSeshApp
//
//  Created by James B Morris on 2/15/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

// This file acts as a storage file for all functions with backend functionality relative to Booking objects.

class BookingAPI {
    
    var REF_BOOKINGS = Database.database().reference().child("bookings") // database address
    
    func observeBookings(withUserId id: String, completion: @escaping (Booking) -> Void) { // observe Booking activity specified with userId of artist that made Booking
        REF_BOOKINGS.child(id).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String : Any] {
                
                let newBooking = Booking.transformBooking(dict: dict)
                completion(newBooking)
            }
        }
    }
    
    //IGNORE:
//    func observeBookings2(withUserId uid: String, completion: @escaping (Booking) -> Void) {
//        REF_BOOKINGS.childByAutoId().child("uid").observeSingleEvent(of: .value) { (snapshot) in
//
//            for snap in snapshot.children {
//                if let snap = snap as? DataSnapshot {
//                    if let dict = snap.value as? [String : Any] {
//                        if let uid = dict[uid] as? [[String: Any]] {
//                            let newBooking = Booking.transformBooking(dict: dict)
//                            completion(newBooking)
//                            print(uid)
//                        }
//                    }
//                }
//            }
//        }
//    }
    
}
