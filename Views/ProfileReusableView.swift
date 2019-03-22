//
//  ProfileReusableView.swift
//  StudioSeshApp
//
//  Created by James B Morris on 8/15/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

protocol ProfileReusableViewDelegate {
    func updateFollowButton(forUser user: User)
}

protocol ProfileReusableViewDelegateSwtichSettingsVC {
    func goToSettingsVC()
}

protocol ProfileReusableViewDelegateSwitchReviewsVC {
    func goToReviewsVC(userId: String)
}

protocol ProfileReusableViewDelegateToFollowers {
    func goToFollowers(userId: String)
}

protocol ProfileReusableViewDelegateToFollowing {
    func goToFollowing(userId: String)
}

class ProfileReusableView: UICollectionReusableView {
    
    @IBOutlet weak var profileUsernameLabel: UILabel!
    
    @IBOutlet weak var profileBioUsernameLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var profilePostCountLabel: UILabel!
    
    @IBOutlet weak var profileFollowerCountLabel: UILabel!
    
    @IBOutlet weak var profileFollowerCountLabel2: UILabel!
    
    @IBOutlet weak var profileFollowingCountLabel: UILabel!
    
    @IBOutlet weak var profileFollowingCountLabel2: UILabel!
    
    @IBOutlet weak var messageBtn: UIButton!
    
    @IBOutlet weak var followBtn: UIButton!
    
    @IBOutlet weak var profileStackView: UIStackView!
    
    @IBOutlet weak var bioLabel: UILabel!
    
    @IBOutlet weak var artformsLabel: UILabel!
    
    @IBOutlet weak var artformsDisplayLabel: UILabel!
    
    @IBOutlet weak var reviewsBtn: UIButton!
    
    var delegate: ProfileReusableViewDelegate?
    
    var delegate2: ProfileReusableViewDelegateSwtichSettingsVC?
    
    var delegate3: ProfileReusableViewDelegateSwitchReviewsVC?
    
    var delegate4: ProfileReusableViewDelegateToFollowers?
    
    var delegate5: ProfileReusableViewDelegateToFollowing?
    
    var currentUser: User!
    
    var user: User? {
        didSet {
            updateView()
        }
    }

    var users = [User]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clear()
        
        let tapGestureForFollowers = UITapGestureRecognizer(target: self, action: #selector(self.goToFollowers))
        profileFollowerCountLabel2.addGestureRecognizer(tapGestureForFollowers)
        profileFollowerCountLabel2.isUserInteractionEnabled = true
        
        let tapGestureForFollowing = UITapGestureRecognizer(target: self, action: #selector(self.goToFollowing))
        profileFollowingCountLabel2.addGestureRecognizer(tapGestureForFollowing)
        profileFollowingCountLabel2.isUserInteractionEnabled = true
    }
    
    @objc func goToFollowers() {
        if let id = user?.id {
            delegate4?.goToFollowers(userId: id)
        }
    }
    
    @objc func goToFollowing() {
        if let id = user?.id {
            delegate5?.goToFollowing(userId: id)
        }
    }
    
    func updateView() {
        self.profileUsernameLabel.text = user!.username
        self.profileBioUsernameLabel.text = user!.username
        if user?.persona == "Artist" {
        self.artformsLabel.text = user!.artforms!
        } else {
            self.artformsDisplayLabel.isHidden = true
        }
        if user?.bio != nil {
          self.bioLabel.text = user!.bio!
        } else {
            print("USER BIO IS NIL")
        }
        if let photoUrlString = user!.profileImageUrl {
            let photoUrl = URL(string: photoUrlString)
            self.profileImageView.sd_setImage(with: photoUrl)
        } else {
            print("Could not load image.")
        }
        
        API.UserPosts.fetchUserPostsCount(userId: user!.id!) { (count) in
            self.profilePostCountLabel.text = "\(count)"
        }
        
        API.Follow.fetchFollowingCount(userId: user!.id!) { (count) in
            self.profileFollowingCountLabel.text = "\(count)"
        }
        
        API.Follow.fetchFollowersCount(userId: user!.id!) { (count) in
            self.profileFollowerCountLabel.text = "\(count)"
        }
        
        if user?.id == API.User.CURRENT_USER?.uid {
            messageBtn.isHidden = true
            followBtn.setTitle("Edit Profile", for: .normal)
            followBtn.addTarget(self, action: #selector(self.goToSettingsVC), for: UIControl.Event.touchUpInside)
            self.followBtn.layer.cornerRadius = followBtn.frame.height / 2
            self.followBtn.backgroundColor = #colorLiteral(red: 0, green: 0.5628422499, blue: 0.3188166618, alpha: 1)
            self.followBtn.setTitleColor(UIColor.white, for: .normal)
            self.followBtn.clipsToBounds = true
        } else {
            updateStateFollowButton()
        }
    }
    
    func clear() {
        self.profileUsernameLabel.text = ""
        self.profileBioUsernameLabel.text = ""
        self.artformsLabel.text = ""
        self.bioLabel.text = ""
        self.profilePostCountLabel.text = ""
        self.profileFollowingCountLabel.text = ""
        self.profileFollowerCountLabel.text = ""
    }
    
    @objc func goToSettingsVC() {
        delegate2?.goToSettingsVC()
    }
    
    func goToReviews() {
        if let id = user?.id {
            delegate3?.goToReviewsVC(userId: id)
        }
    }
    
    @IBAction func reviewBtnWasPressed(_ sender: Any) {
        goToReviews()
    }
    
    @IBAction func messageBtnWasPressed(_ sender: Any) {
        
        NotificationCenter.default.post(name: NSNotification.Name.init("newMessage"), object: nil, userInfo: [
            "message":user!
        ])
    }
    
    
    
    func updateStateFollowButton() {
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
        self.followBtn.layer.cornerRadius = followBtn.frame.height / 2
        self.followBtn.layer.borderWidth = 1
        self.followBtn.layer.borderColor = UIColor(red: 226/255, green: 228/255, blue: 232/255, alpha: 1.0).cgColor
        self.followBtn.clipsToBounds = true
        self.followBtn.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        self.followBtn.setTitleColor(UIColor.white, for: .normal)
    }
    
    func configureUnfollowBtn() {
        self.followBtn.setTitle("Following", for: .normal)
        followBtn.addTarget(self, action: #selector(self.unfollowAction), for: UIControl.Event.touchUpInside)
        self.followBtn.layer.cornerRadius = followBtn.frame.height / 2
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
            delegate?.updateFollowButton(forUser: user!)
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
            delegate?.updateFollowButton(forUser: user!)
        }
    }
    
    
        
}
