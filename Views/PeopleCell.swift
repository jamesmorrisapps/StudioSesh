//
//  PeopleCell.swift
//  StudioSeshApp
//
//  Created by James B Morris on 8/31/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

protocol PeopleCellDelegate:AnyObject {
    func goToProfileUserVC(userId: String)
}

class PeopleCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var followBtn: UIButton!
    
    var delegate: PeopleCellDelegate?
    
    var user: User? {
        didSet {
            updateView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.layer.cornerRadius = profileImageView.layer.frame.height / 2
        
        followBtn.layer.cornerRadius = 5
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.goToUserProfile))
        usernameLabel.addGestureRecognizer(tapGesture)
        usernameLabel.isUserInteractionEnabled = true
    }
    
    @objc func goToUserProfile() {
        if let id = user?.id {
            delegate?.goToProfileUserVC(userId: id)
        }
    }
    
    func updateView() {
        usernameLabel.text = user?.username
        if let photoUrlString = user?.profileImageUrl {
            let photoUrl = URL(string: photoUrlString)
            profileImageView.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "cameraPlaceholder"))
        }
        
        API.Follow.isFollowing(userId: user!.id!) { (value) in
            if value {
                self.configureUnfollowBtn()
            } else {
                self.configureFollowBtn()
            }
        }
    }
    
    func configureFollowBtn() {
        self.followBtn.setTitle("Follow", for: .normal)
        followBtn.addTarget(self, action: #selector(self.followAction), for: UIControl.Event.touchUpInside)
        self.followBtn.layer.borderWidth = 1
        self.followBtn.layer.borderColor = UIColor(red: 226/255, green: 228/255, blue: 232/255, alpha: 1.0).cgColor
        self.followBtn.clipsToBounds = true
        self.followBtn.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        self.followBtn.setTitleColor(UIColor.white, for: .normal)
    }
    
    func configureUnfollowBtn() {
        self.followBtn.setTitle("Following", for: .normal)
        followBtn.addTarget(self, action: #selector(self.unfollowAction), for: UIControl.Event.touchUpInside)
        self.followBtn.layer.borderWidth = 1
        self.followBtn.layer.borderColor = UIColor.clear.cgColor
        self.followBtn.clipsToBounds = true
        self.followBtn.backgroundColor = #colorLiteral(red: 0, green: 0.5628422499, blue: 0.3188166618, alpha: 1)
        self.followBtn.setTitleColor(UIColor.white, for: .normal)
    }
    
    @objc func followAction() {
        if user!.isFollowing! == false {
            API.Follow.followAction(withUser: user!.id!)
            configureUnfollowBtn()
            user!.isFollowing! = true
        }
        let timestamp = Int(Date().timeIntervalSince1970)
        let ref = Database.database().reference()
        let postsReference = ref.child("postedContent")
        let newPostId = postsReference.childByAutoId().key
        API.Follow.REF_FOLLOWERS.child(API.User.CURRENT_USER!.uid).observe(.value, with: { (snapshot) in
            let arraySnapshot = snapshot.children.allObjects as! [DataSnapshot]
            arraySnapshot.forEach({ (child) in
                API.Feed.REF_FEED.child(child.key).updateChildValues(["\(newPostId)" : true])
                let newNotificationId = API.Notification.REF_NOTIFICATIONS.child(child.key).childByAutoId().key
                let newNotificationReference = API.Notification.REF_NOTIFICATIONS.child(child.key).child(newNotificationId)
                newNotificationReference.setValue(["from" : API.User.CURRENT_USER!.uid, "type" : "follow", "objectId" : newPostId, "timestamp" : timestamp])
            })
        })
    }
    
    @objc func unfollowAction() {
        if user!.isFollowing! == true {
            API.Follow.unfollowAction(withUser: user!.id!)
            configureFollowBtn()
            user!.isFollowing! = false
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
