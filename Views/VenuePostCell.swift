//
//  VenuePostCell.swift
//  StudioSeshApp
//
//  Created by James B Morris on 8/10/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

protocol VenueCellDelegate:AnyObject {
    func performVenueSegue(_ id:String,sender:String)
}

class VenuePostCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var bottomUsernameLabel: UILabel!
    
    @IBOutlet weak var priceView: UIView!
    
    @IBOutlet weak var shareBtn: UIImageView!
    
   weak var delegate:VenueCellDelegate?
    
    var postRef: DatabaseReference!
    
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
    
    func updateViews() {
        if let photoUrlString = post?.photoUrl {
            let photoUrl = URL(string: photoUrlString)
            profileImageView.sd_setImage(with: photoUrl)
        }
        setupUserInfo()
    }
    
    func setupUserInfo() {
        usernameLabel.text = user?.username
        bottomUsernameLabel.text = user?.username
        priceLabel.text = post?.price
        if let photoUrlString = user?.profileImageUrl {
            let photoUrl = URL(string: photoUrlString)
            profileImageView.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "cameraPlaceholder"))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        usernameLabel.text = ""
        priceLabel.text = ""
        bottomUsernameLabel.text = ""
        priceView.layer.cornerRadius = 10
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        profileImageView.image = UIImage(named: "cameraPlaceholder")
    }
    
}

extension VenuePostCell: SettingsVCDelegate {
    func updateUserInfo() {
        self.setupUserInfo()
    }
}
