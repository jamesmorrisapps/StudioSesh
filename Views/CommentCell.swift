//
//  CommentCell.swift
//  StudioSeshApp
//
//  Created by James B Morris on 8/8/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import UIKit
import KILabel

protocol CommentCellDelegate:AnyObject {
    func goToProfileUserVC(userId: String)
    func goToHashtag(tag: String)
}

class CommentCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var commentLabel: KILabel!
    
    var delegate: CommentCellDelegate?
    
    var comment: Comment? {
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
        commentLabel.text = comment?.commentText
        
        commentLabel.hashtagLinkTapHandler = { label, string, range in
            print(string)
            let tag = String(string.dropFirst())
            self.delegate?.goToHashtag(tag: tag)
        }
        commentLabel.userHandleLinkTapHandler = { label, string, range in
            print(string)
            let mention = String(string.dropFirst())
            print(mention)
            API.User.observeUsersByUsername(username: mention.lowercased().trimmingCharacters(in: .whitespacesAndNewlines), completion: { (user) in
                self.delegate?.goToProfileUserVC(userId: user)
            })
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
        commentLabel.text = ""
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        
        let tapGestureForUser = UITapGestureRecognizer(target: self, action: #selector(self.goToUserProfile))
        usernameLabel.addGestureRecognizer(tapGestureForUser)
        usernameLabel.isUserInteractionEnabled = true
    }
    
    @objc func goToUserProfile() {
        if let id = user?.id {
            delegate?.goToProfileUserVC(userId: id)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        profileImageView.image = UIImage(named: "cameraPlaceholder")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}

extension CommentCell: SettingsVCDelegate {
    func updateUserInfo() {
        self.setupUserInfo()
    }
}
