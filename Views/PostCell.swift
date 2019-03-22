//
//  PostCell.swift
//  StudioSeshApp
//
//  Created by James B Morris on 8/4/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import UIKit
import KILabel
import AVFoundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

protocol PostCellDelegate:AnyObject {
    func performSegue(_ id:String,sender:String)
    func goToProfileUserVC(userId: String)
    func goToHashtag(tag: String)
}

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var likeImageView: UIImageView!
    
    @IBOutlet weak var commentImageView: UIImageView!
    
    @IBOutlet weak var shareImageView: UIImageView!
    
    @IBOutlet weak var moreImageView: UIImageView!
    
    @IBOutlet weak var likeCountBtn: UIButton!
    
    @IBOutlet weak var captionLabel: KILabel!
    
    @IBOutlet weak var videoVolumeView: UIImageView!
    
    @IBOutlet weak var videoVolumeBtn: UIButton!
    
    @IBOutlet weak var photoHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var timestampLabel: UILabel!
    
    //var homeVC: Search_HistoryVC?
    weak var delegate:PostCellDelegate?
    
    var postRef: DatabaseReference!
    
    var player: AVPlayer?
    
    var playerLayer: AVPlayerLayer?
    
    var isMuted = true
    
    var post: Posts? {
        didSet {
            updateViews()
        }
    }
    
    var user: User? {
        didSet {
            setupUserInfo()
        }
    }
    
    override func layoutSubviews() {
        updateViews()
    }
    
    func updateViews() {
        captionLabel.text = post?.caption
        captionLabel.hashtagLinkTapHandler = { label, string, range in
            print(string)
            let tag = String(string.dropFirst())
            self.delegate?.goToHashtag(tag: tag)
        }
        captionLabel.userHandleLinkTapHandler = { label, string, range in
            print(string)
            let mention = String(string.dropFirst())
            print(mention)
            API.User.observeUsersByUsername(username: mention.lowercased().replacingOccurrences(of: " ", with: "_"), completion: { (user) in
                self.delegate?.goToProfileUserVC(userId: user)
            })
        }
        print("ratio: \(String(describing: post?.ratio))")
        if let ratio = post?.ratio {
            print("frame post image: \(postImageView.frame)")
            photoHeightConstraint.constant = UIScreen.main.bounds.width / ratio
            layoutIfNeeded()
            print("frame post image: \(postImageView.frame)")
        }
        
        if let photoUrlString = post?.photoUrl {
            let photoUrl = URL(string: photoUrlString)
            postImageView.sd_setImage(with: photoUrl)
        }
        if let videoUrlString = post?.videoUrl, let videoUrl = URL(string: videoUrlString) {
           self.videoVolumeView.isHidden = false
            self.videoVolumeBtn.isHidden = false
            let layers = self.contentView.layer.sublayers
            if layers == nil || !layers!.contains(where: {
                $0 is AVPlayerLayer
            }) {
                player = AVPlayer(url: videoUrl)
                playerLayer = AVPlayerLayer(player: player)
                self.contentView.layer.addSublayer(playerLayer!)
                self.videoVolumeView.layer.zPosition = 1
                self.videoVolumeBtn.layer.zPosition = 2
                player?.play()
                player?.isMuted = isMuted
            }
            playerLayer?.frame = postImageView.frame
        }
        setupUserInfo()
        
        if let timestamp = post?.timestamp {
            let timestampDate = Date(timeIntervalSince1970: Double(timestamp))
            let now = Date()
            let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfMonth, .month, .year])
            let diff = Calendar.current.dateComponents(components, from: timestampDate, to: now)
            var timeText = ""
            
            if diff.second! <= 0 {
                timeText = "Posted now"
            }
            if diff.second! > 0 && diff.minute! == 0 {
                timeText = (diff.second! == 1) ? "Posted \(diff.second!) second ago" : "Posted \(diff.second!) seconds ago"
            }
            if diff.minute! > 0 && diff.hour! == 0 {
                timeText = (diff.minute! == 1) ? "Posted \(diff.minute!) minute ago" : "Posted \(diff.minute!) minutes ago"
            }
            if diff.hour! > 0 && diff.day! == 0 {
                timeText = (diff.hour! == 1) ? "Posted \(diff.hour!) hour ago" : "Posted \(diff.hour!) hours ago"
            }
            if diff.day! > 0 && diff.weekOfMonth! == 0 {
                timeText = (diff.day! == 1) ? "Posted \(diff.day!) day ago" : "Posted \(diff.day!) days ago"
            }
            if diff.weekOfMonth! > 0 && diff.month! == 0 {
                timeText = (diff.weekOfMonth! == 1) ? "Posted \(diff.weekOfMonth!) week ago" : "Posted \(diff.weekOfMonth!) weeks ago"
            }
            if diff.month! > 0 && diff.year! == 0 {
                timeText = (diff.month! == 1) ? "Posted \(diff.month!) month ago" : "Posted \(diff.month!) months ago"
            }
            if diff.year! > 0 {
                timeText = (diff.year! == 1) ? "Posted \(diff.year!) year ago" : "Posted \(diff.year!) years ago"
            }
            
            timestampLabel.text = timeText
        }
        
        self.updateLikes(post: self.post!)
    }
    
    @IBAction func videoVolumeBtnWasPressed(_ sender: UIButton) {
        if isMuted {
            isMuted = !isMuted
            videoVolumeBtn.setImage(#imageLiteral(resourceName: "Icon_Volume"), for: .normal)
        } else {
            isMuted = !isMuted
            videoVolumeBtn.setImage(#imageLiteral(resourceName: "Icon_Mute"), for: .normal)
        }
            player?.isMuted = isMuted
    }
    
    func updateLikes(post: Posts) {

        let imageName = post.likes == nil || !post.isLiked! ? "like" : "likeSelected"
        likeImageView.image = UIImage(named: imageName)
        guard let count = post.likeCount else {
            return
        }
        if count != 0 {
            likeCountBtn.setTitle("\(String(describing: count)) likes", for: .normal)
        } else {
            likeCountBtn.setTitle("Be the first to like this post", for: .normal)
        }
    }
    
    func setupUserInfo() {
        usernameLabel.text = user?.username
        if let photoUrlString = user?.profileImageUrl {
            let photoUrl = URL(string: photoUrlString)
            profileImageView.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "cameraPlaceholder"))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        usernameLabel.text = ""
        captionLabel.text = ""
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.goToComments))
        commentImageView.addGestureRecognizer(tapGesture)
        commentImageView.isUserInteractionEnabled = true
        
        let tapGestureForLikes = UITapGestureRecognizer(target: self, action: #selector(self.like))
        likeImageView.addGestureRecognizer(tapGestureForLikes)
        likeImageView.isUserInteractionEnabled = true
        
        let tapGestureForUser = UITapGestureRecognizer(target: self, action: #selector(self.goToUserProfile))
        usernameLabel.addGestureRecognizer(tapGestureForUser)
        usernameLabel.isUserInteractionEnabled = true
        
//        let tapGestureForVolume = UITapGestureRecognizer(target: self, action: #selector(self.configureVideoVolume))
//        videoVolumeBtn.addGestureRecognizer(tapGestureForVolume)
//        videoVolumeBtn.isUserInteractionEnabled = true
    }
    
    @objc func goToComments() {
        if let id = post?.id {
            delegate?.performSegue("toComments", sender: id)
        }
    }
    
    @objc func goToUserProfile() {
        if let id = user?.id {
            delegate?.goToProfileUserVC(userId: id)
        }
    }
    
    @objc func like() {
        postRef = API.Post.REF_POSTS.child((post?.id)!)
        self.post?.likes = post?.likes
        self.post?.isLiked = post?.isLiked
        self.post?.likeCount = post?.likeCount
        incrementLikes(forRef: postRef)
    }
    
    func incrementLikes(forRef ref: DatabaseReference) {
        ref.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var post = currentData.value as? [String : AnyObject], let uid = Auth.auth().currentUser?.uid {
                var likes: Dictionary<String, Bool>
                likes = post["likes"] as? [String : Bool] ?? [:]
                var likeCount = post["likeCount"] as? Int ?? 0
                if let _ = likes[uid] {
                    // Unlike the post and remove self from likes
                    likeCount -= 1
                    likes.removeValue(forKey: uid)
                } else {
                    // Like the post and add self to likes
                    likeCount += 1
                    likes[uid] = true
                    
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
                            if let postId = self.post?.id {
                                newNotificationReference.setValue(["from" : API.User.CURRENT_USER!.uid, "type" : "like", "objectId" : postId, "timestamp" : timestamp])
                            }else{
                               print("post id does not exist")
                            }
                            
                        })
                    })
                }
                post["likeCount"] = likeCount as AnyObject?
                post["likes"] = likes as AnyObject?
                
                // Set value and report transaction success
                currentData.value = post
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshotLike) in
            if let error = error {
                print(error.localizedDescription)
            }
            if let dict = snapshotLike?.value as? [String : Any] {
                let post = Posts.transformPostPhoto(dict: dict, key: (snapshotLike?.key)!)
                self.updateLikes(post: post)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.videoVolumeView.isHidden = true
        self.videoVolumeBtn.isHidden = true
        profileImageView.image = UIImage(named: "cameraPlaceholder")
        playerLayer?.removeFromSuperlayer()
        player?.pause()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
}

extension PostCell: SettingsVCDelegate {
    func updateUserInfo() {
        self.setupUserInfo()
    }
}
