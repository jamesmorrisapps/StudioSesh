//
//  ArtFormCollectionViewCell.swift
//  StudioSeshApp
//
//  Created by James B Morris on 7/31/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

class ArtFormCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var artFormImage: UIImageView!
    
    @IBOutlet weak var artFormLabel: UILabel!
    
    @IBOutlet weak var artFormSelectedImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        artFormImage.layer.cornerRadius = artFormImage.bounds.width / 2
        artFormImage.contentMode = .scaleAspectFill
        artFormImage.clipsToBounds = true
        artFormSelectedImage.layer.cornerRadius = artFormImage.bounds.width / 2
        artFormSelectedImage.contentMode = .scaleAspectFill
        artFormSelectedImage.clipsToBounds = true
    }
    
    
}
