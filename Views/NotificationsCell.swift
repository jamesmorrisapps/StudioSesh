//
//  NotificationsCell.swift
//  StudioSeshApp
//
//  Created by James B Morris on 11/29/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import UIKit
import UserNotifications
import FirebaseMessaging

protocol NotificationsCellDelegate:AnyObject {
    func goToDetailVC(notification: Notification)
}

class NotificationsCell: UITableViewCell {
    
    @IBOutlet weak var timestampLabel: UILabel!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var postImage: UIImageView!
    
    var delegate: NotificationsCellDelegate?
    
    var notification: Notification? {
        didSet {
            updateViews()
        }
    }
    
    var user: User? {
        didSet {
            setupUserInfo()
        }
    }
    
    func updateViews() {
        switch notification?.type {
        case "feed":
            descriptionLabel.text = "added a new post."
            let postId = notification!.objectId!
            API.Post.observePost(withId: postId) { (post) in
                print("post id:\(post)")
                if let photoUrlString = post.photoUrl {
                    let photoUrl = URL(string: photoUrlString)
                    DispatchQueue.main.async {
                        self.postImage.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "cameraPlaceholder"))
                    }
                }
            }
            
//            let content = UNMutableNotificationContent()
//            content.title = "\(user!.username!)"
//            content.body = "added a new post."
//            content.sound = UNNotificationSound.default
//
//            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
//
//            let request = UNNotificationRequest(identifier: "post", content: content, trigger: trigger)
//
//            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
            ;
        case "follow":
            descriptionLabel.text = "followed you."
            self.postImage.image = nil
            
//            let content = UNMutableNotificationContent()
//            content.title = "\(user!.username!)"
//            content.body = "followed you."
//            content.sound = UNNotificationSound.default
//
//            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
//
//            let request = UNNotificationRequest(identifier: "follow", content: content, trigger: trigger)
//
//            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        case "like":
            descriptionLabel.text = "liked your post."
            let postId = notification!.objectId!
            DispatchQueue.global().async {
                API.Post.observePost(withId: postId) { (post) in
                    if let photoUrlString = post.photoUrl {
                        let photoUrl = URL(string: photoUrlString)
                        self.postImage.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "cameraPlaceholder"))
                    }else{
                        print("ERROR!!!")
                    }
                };
            }
            
//            let content = UNMutableNotificationContent()
//            content.title = "\(user!.username!)"
//            content.body = "liked your post."
//            content.sound = UNNotificationSound.default
//
//            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
//
//            let request = UNNotificationRequest(identifier: "like", content: content, trigger: trigger)
//
//            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        case "comment":
            descriptionLabel.text = "commented on your post."
            let postId = notification!.objectId!
            API.Post.observePost(withId: postId) { (post) in
                if let photoUrlString = post.photoUrl {
                    let photoUrl = URL(string: photoUrlString)
                    self.postImage.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "cameraPlaceholder"))
                }else{
                    print("ERROR!!!")
                }
            }
//            let content = UNMutableNotificationContent()
//            content.title = "\(user!.username!)"
//            content.body = "commented on your post."
//            content.sound = UNNotificationSound.default
//
//            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
//
//            let request = UNNotificationRequest(identifier: "comment", content: content, trigger: trigger)
//
//            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
            ;
        case "message":
            descriptionLabel.text = "messaged you."
            
//            let content = UNMutableNotificationContent()
//            content.title = "\(user!.username!)"
//            content.body = "messaged you."
//            content.sound = UNNotificationSound.default
//
//            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
//
//            let request = UNNotificationRequest(identifier: "message", content: content, trigger: trigger)
//
//            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        case "review":
            descriptionLabel.text = "reviewed you."
            
//            let content = UNMutableNotificationContent()
//            content.title = "\(user!.username!)"
//            content.body = "reviewed you."
//            content.sound = UNNotificationSound.default
//
//            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
//
//            let request = UNNotificationRequest(identifier: "review", content: content, trigger: trigger)
//
//            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        case "booking":
            descriptionLabel.text = "booked your venue."
            
//            let content = UNMutableNotificationContent()
//            content.title = "\(user!.username!)"
//            content.body = "booked your venue."
//            content.sound = UNNotificationSound.default
//
//            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
//
//            let request = UNNotificationRequest(identifier: "booking", content: content, trigger: trigger)
//
//            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        default:
            print("fvtvbybuinmiofghj")
        }
        
        if let timestamp = notification?.timestamp {
            let timestampDate = Date(timeIntervalSince1970: Double(timestamp))
            let now = Date()
            let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfMonth, .month, .year])
            let diff = Calendar.current.dateComponents(components, from: timestampDate, to: now)
            var timeText = ""
            
            if diff.second! <= 0 {
                timeText = "Now"
            }
            if diff.second! > 0 && diff.minute! == 0 {
                timeText = "\(diff.second!)s"
            }
            if diff.minute! > 0 && diff.hour! == 0 {
                timeText = "\(diff.minute!)m"
            }
            if diff.hour! > 0 && diff.day! == 0 {
                timeText = "\(diff.hour!)h"
            }
            if diff.day! > 0 && diff.weekOfMonth! == 0 {
                timeText = "\(diff.day!)d"
            }
            if diff.weekOfMonth! > 0 && diff.month! == 0 {
                timeText = "\(diff.weekOfMonth!)w"
            }
            if diff.month! > 0 && diff.year! == 0 {
                timeText = "\(diff.month!)mo"
            }
            if diff.year! > 0 {
                timeText = "\(diff.year!)y"
            }
            
            timestampLabel.text = timeText
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.cellTapped))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }
    
    @objc func cellTapped() {
        if let notification = notification{
            delegate?.goToDetailVC(notification: notification)
        }
    }
    
    func setupUserInfo() {
        usernameLabel.text = user?.username
        if let photoUrlString = user?.profileImageUrl {
            let photoUrl = URL(string: photoUrlString)
            profileImage.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "cameraPlaceholder"))
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
