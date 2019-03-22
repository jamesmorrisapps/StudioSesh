//
//  API.swift
//  StudioSeshApp
//
//  Created by James B Morris on 8/10/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import Foundation

// This file acts as a storage file for all of StudioSesh's data APIs, and allows access of each of their embedded functions from anywhere in the app.

struct API {
    static var User = UserAPI()
    static var Post = PostAPI()
    static var Comment = CommentAPI()
    static var Post_Comment = Post_CommentAPI()
    static var UserPosts = UserPostAPI()
    static var VenuePosts = VenuePostAPI()
    static var Follow = FollowAPI()
    static var Feed = FeedAPI()
    static var User_Artform = User_ArtformAPI()
    static var Artforms = ArtformsAPI()
    static var Hashtag = HashtagAPI()
    static var Notification = NotificationsAPI()
    static var Sessions = MessengerChannelAPI()
    static var Reviews = ReviewAPI()
    static var User_Review = User_ReviewAPI()
    static var Bookings = BookingAPI()
    static var Venue_Booking = Venue_BookingAPI()
    static var User_Booking = User_BookingAPI()
}
