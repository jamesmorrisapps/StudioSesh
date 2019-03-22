//
//  Comment.swift
//  StudioSeshApp
//
//  Created by James B Morris on 8/8/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import Foundation

// This file contains a model of Comments: small tokens of opinion that both artists and venues can leave on other artists' posts.

class Comment {
    var commentText: String? // actual text of Comment left by User
    var uid: String? // userId of User that posted Comment
}

extension Comment {
    // compile and transform Comments and respective data into an array of dictionaries, then return such as a Comment object (useful for working with and displaying Comments in Comment view)
    static func transformComment(dict: [String : Any]) -> Comment {
        let comment = Comment()
        comment.commentText = dict["commentText"] as? String
        comment.uid = dict["uid"] as? String
        return comment
    }
}
