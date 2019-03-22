//
//  SessionFeedCell.swift
//  StudioSeshApp
//
//  Created by James B Morris on 12/28/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import UIKit

class SessionFeedCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configureCell(profileImage image: String, username: String, content: String) {
        //self.profileImage.image = image
        self.usernameLabel.text = username
        self.contentLabel.text = content
        DispatchQueue.global().async {
            self.updateImage(image)
        }
    }
    
    func updateImage(_ url:String?){
        if let photoUrlString = url {
            let photoUrl = URL(string: photoUrlString)
            DispatchQueue.main.async {
                self.profileImage.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "cameraPlaceholder"))
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
