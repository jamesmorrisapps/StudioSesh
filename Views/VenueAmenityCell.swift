//
//  VenueAmenityCell.swift
//  StudioSeshApp
//
//  Created by James B Morris on 3/20/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit

class VenueAmenityCell: UITableViewCell {
    
    @IBOutlet weak var amenityLabel: UILabel!
    
    @IBOutlet weak var checkmarkImage: UIImageView!
    
    var showing = false

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configureCell(amenity: String, isSelected: Bool) {
        amenityLabel.text = amenity
        if isSelected {
            self.checkmarkImage.isHidden = false
        } else {
            self.checkmarkImage.isHidden = true
        }
    }

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
