//
//  UserBookingCell.swift
//  StudioSeshApp
//
//  Created by James B Morris on 2/17/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit

class UserBookingCell: UITableViewCell {
    
    @IBOutlet weak var venueNameLabel: UILabel!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var checkinDateLabel: UILabel!
    
    @IBOutlet weak var checkoutDateLabel: UILabel!
    
    var booking: Booking? {
        didSet {
            updateViews()
        }
    }
    
    var user: User? {
        didSet {
          //  setupUserInfo()
        }
    }
    
    func updateViews() {
        API.User.observeUsers(withId: (booking?.id)!) { (user) in
            self.venueNameLabel.text = user.username
            if let photoUrlString = user.profileImageUrl {
                let photoUrl = URL(string: photoUrlString)
                self.profileImage.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "cameraPlaceholder"))
            }
        }
        checkinDateLabel.text = booking?.checkinDate
        checkoutDateLabel.text = booking?.checkoutDate
        print("Check-In Date: \(checkinDateLabel.text!)")
        print("Check-Out Date: \(checkoutDateLabel.text!)")
    }
    
//    func setupUserInfo() {
//        venueNameLabel.text = user?.username
//    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        venueNameLabel.text = ""
        checkinDateLabel.text = ""
        checkoutDateLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
