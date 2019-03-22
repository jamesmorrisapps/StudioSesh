//
//  ReviewCell.swift
//  StudioSeshApp
//
//  Created by James B Morris on 1/3/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit

class ReviewCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var reviewPercentageLabel: UILabel!
    
    @IBOutlet weak var reviewTextLabel: UILabel!
    
    var review: Review? {
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
        reviewTextLabel.text = review?.reviewText
        guard let per = review?.reviewPercentage else{
            return
        }
        reviewPercentageLabel.text = "\(per)%"
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
        
        usernameLabel.text = ""
        reviewTextLabel.text = ""
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateViews()
        setupUserInfo()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
