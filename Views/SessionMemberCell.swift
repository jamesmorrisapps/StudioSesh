//
//  SessionMemberCell.swift
//  StudioSeshApp
//
//  Created by James B Morris on 12/24/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import UIKit

class SessionMemberCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var checkmarkImage: UIImageView!
    
//    var user: User? {
//        didSet {
//            updateView()
//        }
//    }
    
    var showing = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configureCell(profileImage image: UIImage, username: String, isSelected: Bool) {
        profileImage.image = image
        usernameLabel.text = username
        if isSelected {
            self.checkmarkImage.isHidden = false
        } else {
            self.checkmarkImage.isHidden = true
        }
    }
    
//    func updateView() {
//        if let photoUrlString = user?.profileImageUrl {
//            let photoUrl = URL(string: photoUrlString)
//            profileImage.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "cameraPlaceholder"))
//        }
//    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            if showing == false {
                checkmarkImage.isHidden = false
                showing = true
            } else {
            checkmarkImage.isHidden = true
                showing = false
            }
        }
    }
    
    
    
}
