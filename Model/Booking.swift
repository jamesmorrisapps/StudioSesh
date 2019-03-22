//
//  Booking.swift
//  StudioSeshApp
//
//  Created by James B Morris on 2/15/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import Foundation

// This file contains a model of Booking: a reservation of a venue by an artist for a set fee.

class Booking {
    var id: String? // Id key of Booking object
    var members: [String]? // array of userIds of those affiliated with the booking (venue and artist)
    var confirmationNumber: String? // confirmationNumber for Users to screenshot as their receipt for their booking
    var checkinDate: String? // check-in date for booking
    var checkoutDate: String? // check-out date for booking
    var price: String? // booking price: set fee by venue for reserving creative space with their establishment
    var uid: String? // userId of User who booked reservation with venue
}

extension Booking {
    // compile and transform Bookings and respective data into an array of dictionaries, then return such as a Bookings object (useful for working with and displaying Bookings in tableViews in other view controllers)
    static func transformBooking(dict: [String : Any]) -> Booking {
        let booking = Booking()
        booking.id = dict["id"] as? String
        booking.members = dict["members"] as? [String]
        booking.confirmationNumber = dict["confirmationNumber"] as? String
        booking.checkinDate = dict["checkinDate"] as? String
        booking.checkoutDate = dict["checkoutDate"] as? String
        booking.price = dict["price"] as? String
        booking.uid = dict["uid"] as? String
        return booking
    }
}

