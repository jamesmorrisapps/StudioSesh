//
//  MessengerChannelAPI.swift
//  StudioSeshApp
//
//  Created by James B Morris on 12/20/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

// This file acts as a storage file for all functions with backend functionality relative to Message objects, as well their parent Session objects.

class MessengerChannelAPI {
    
    var REF_MESSAGES = Database.database().reference().child("messages") // database address (message: direct conversations)
    
    var REF_SESSIONS = Database.database().reference().child("sessions") // database address (session: group conversations/channels)
    
    func observeMessages(forSessionId id: String, completion: @escaping (Message) -> Void) { //observe Message activity specified by Session Id key
        API.Sessions.REF_SESSIONS.child(id).child("messages").observe(.childAdded) { (snapShot) in
            guard let value = snapShot.value as? [String : String] else{
                return
            }
            completion(Message(value))
        }
    }
    
    func uploadMessage(withMessage message: String, forUID uid: String, withSessionKey sessionKey: String?, sendComplete: @escaping (_ status: Bool) -> ()) { // upload Message into stored parent Session Messages
        
        if sessionKey != nil {
            REF_SESSIONS.child(sessionKey!).child("messages").childByAutoId().updateChildValues(["content" : message, "senderId" : uid])
            
                sendComplete(true)
        } else {
            REF_MESSAGES.childByAutoId().updateChildValues(["content" : message, "senderId" : uid])
            sendComplete(true)
        }
        
    }
    
    func getUsername(forUID uid: String, handler: @escaping (_ username: String) -> ()) { // get the username of a specified User with userId by looking up Users with said userId
        API.User.REF_USERS.observeSingleEvent(of: .value) { (snapshot) in
            guard let userSnapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            for user in userSnapshot {
                if user.key == uid {
                    handler(user.childSnapshot(forPath: "username").value as! String)
                }
            }
        }
    }
    
    func getUsername(forSearchQuery query: String, handler: @escaping (_ usernameArray: [String]) -> ()) { // pull username from User userIds in Session members array by looking up Users with said userId, when searching (to add) Session members
        var usernameArray = [String]()
        API.User.REF_USERS.observe(.value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for user in userSnapshot {
                let username = user.childSnapshot(forPath: "username").value as! String
                
                    if username.lowercased().contains(query) == true {
                        usernameArray.append(username)
                    }
            }
            handler(usernameArray)
            print("Usernames: \(usernameArray)")
        }
    }
    
    func getIds(forUsernames usernames: [String], handler: @escaping ( _ uidArray: [String]) -> ()) { // get the userId of a specified User with username by looking up userId of User with said username
        API.User.REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            var idArray = [String]()
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for user in userSnapshot {
                let username = user.childSnapshot(forPath: "username").value as! String
                
                if usernames.contains(username) {
                    idArray.append(user.key)
                }
            }
            handler(idArray)
        }
    }
    
    func getUsernamesFor(session: Session, handler: @escaping (_ usernamesArray: [String]) -> ()) { // pull username from User userIds in Session members array by looking up Users with said userId
        var usernamesArray = [String]()
        API.User.REF_USERS.observeSingleEvent(of: .value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for user in userSnapshot {
                if session.members.contains(user.key) {
                    let username = user.childSnapshot(forPath: "username").value as! String
                    usernamesArray.append(username)
                }
            }
            handler(usernamesArray)
        }
    }
    
    func createGroup(withTitle title: String, andDescription description: String, forUserIds ids: [String], handler: @escaping (_ groupCreated: Bool) -> ()) { // create a new Session with a title, brief description, and added members
        REF_SESSIONS.childByAutoId().updateChildValues(["title" : title, "description" : description, "members" : ids])
        handler(true)
    }
    
    func getAllSessions(handler: @escaping (_ sessionsArray: [Session]) -> ()) { // load all existing Sessions from the database
        var sessionsArray = [Session]()
        REF_SESSIONS.observeSingleEvent(of: .value) { (sessionSnapshot) in
            guard let sessionSnapshot = sessionSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for session in sessionSnapshot {
                let memberArray = session.childSnapshot(forPath: "members").value as! [String]
                if memberArray.contains((Auth.auth().currentUser?.uid)!) {
                    let title = session.childSnapshot(forPath: "title").value as! String
                    let description = session.childSnapshot(forPath: "description").value as! String
                    let session = Session(title: title, description: description, memberCount: memberArray.count, members: memberArray, key: session.key)
                    sessionsArray.append(session)
                }
            }
            handler(sessionsArray)
        }
    }
    
    func getAllMessagesFor(desiredSession: Session, handler: @escaping (_ messagesArray: [Message]) -> ()) { // load all existing Messages from parents Sessions from the database
        var sessionMessageArray = [Message]()
        REF_SESSIONS.child(desiredSession.key).child("messages").observeSingleEvent(of: .value) { (sessionMessageSnapshot) in
            guard let sessionMessageSnapshot = sessionMessageSnapshot.children.allObjects as? [DataSnapshot] else { return }
            for sessionMessage in sessionMessageSnapshot {
                let content = sessionMessage.childSnapshot(forPath: "content").value as! String
                let senderId = sessionMessage.childSnapshot(forPath: "senderId").value as! String
                let sessionMessage = Message(content: content, senderId: senderId)
                sessionMessageArray.append(sessionMessage)
            }
            handler(sessionMessageArray)
        }
    }
    
    
    
    
    
    
}
