//
//  PhotoCell.swift
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

protocol PhotoCellDelegate:AnyObject {
    func goToDetailVC(postId: String)
}

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var photo: UIImageView!
    
    var delegate: PhotoCellDelegate?
    
    var post: Posts? {
        didSet {
            updateViews()
        }
    }
    
    var user: User? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        if let photoUrlString = post?.photoUrl {
            let photoUrl = URL(string: photoUrlString)
            photo.sd_setImage(with: photoUrl)
        }
        
        if user?.persona == "venue" {
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "shouldUpdateFeed"), object: nil, queue: .main) { (notification) in
                guard let info = notification.userInfo else {
                    assert(false, "info is nil")
                    return
                }
                let image = info["image"] as? UIImage
                self.photo.image = image
            }
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.goToDetail))
        photo.addGestureRecognizer(tapGesture)
        photo.isUserInteractionEnabled = true
    }
    
   @objc func goToDetail() {
        if let id = post?.id {
        delegate?.goToDetailVC(postId: id)
        }
    }
    
    
    
    
}
