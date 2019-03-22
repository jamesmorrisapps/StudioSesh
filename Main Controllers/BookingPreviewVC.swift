//
//  BookingPreviewVC.swift
//  StudioSeshApp
//
//  Created by James B Morris on 3/18/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

class BookingPreviewVC: UIViewController {
    
    @IBOutlet weak var profileCollectionView: UICollectionView!
    
    @IBOutlet weak var confirmBtn: UIButton!
    
    @IBOutlet weak var closeBtn: UIButton!
    
    @IBOutlet weak var profileView: ProfileReusableView!
    
    var user: User!
    var userId = ""
    var post: Posts!
    var price: String!
    var posts: [Posts] = []
    var users = [User]()
    
    func initData(forVenue venue: User, forPost post: Posts, forPrice price: String) {
        self.user = venue
        self.post = post
        self.price = price
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileCollectionView.dataSource = self
        profileCollectionView.delegate = self
        fetchUser()
        fetchUserPosts()
        userId = user.id!
        print("userID: \(userId)")
    }
    
    func fetchUser() {
        API.User.observeUsers(withId: user.id!) { (user) in
            self.isFollowing(userId: user.id!, completed: { (value) in
                user.isFollowing = value
                self.user = user
                self.navigationItem.title = user.username
                self.profileCollectionView.reloadData()
            })
        }
    }
    
    func isFollowing(userId: String, completed: @escaping (Bool) -> Void) {
        API.Follow.isFollowing(userId: userId, completed: completed)
    }
    
    func fetchUserPosts() {
//        guard let currentUser = Auth.auth().currentUser else {
//            return
//        }
        API.UserPosts.REF_USER_POSTS.child(user.id!).observe(.childAdded) { (snapshotUserPost) in
            API.Post.observePost(withId: snapshotUserPost.key, completion: { (post) in
                self.posts.append(post)
                self.profileCollectionView.reloadData()
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toReviews" {
            let reviewsVC = segue.destination as! ReviewsVC
            let userId = sender as! String
            reviewsVC.userId = userId
        }
    }
    
    @IBAction func confirmBtnWasPressed(_ sender: Any) {
        guard let bookingVC = storyboard?.instantiateViewController(withIdentifier: "BookingVC") as? BookingVC else { return }
        bookingVC.initData(forVenue: user, forPost: post, forPrice: price)
        self.present(bookingVC, animated: true, completion: nil)
    }
    
    @IBAction func closeBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }


}

extension BookingPreviewVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if posts.count == 0 {
            profileCollectionView.setEmptyViewProfile(title: "No posts yet.", message: "Tap share to share some content!")
        }
        else {
            profileCollectionView.restore()
        }
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = profileCollectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCell
        let post = posts[indexPath.row]
        cell.post = post
        //cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let profileReusableView = profileCollectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "profileReusableView", for: indexPath) as! ProfileReusableView
        
        if let user = self.user {
            profileReusableView.user = user
            //profileReusableView.delegate2 = self
            profileReusableView.delegate3 = self
            //profileReusableView.delegate4 = self
            //profileReusableView.delegate5 = self
        }
        return profileReusableView
    }
    
}

extension BookingPreviewVC:ProfileReusableViewDelegateSwitchReviewsVC {
    func goToReviewsVC(userId: String) {
        performSegue(withIdentifier: "toReviews", sender: userId)
    }
}

extension BookingPreviewVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: profileCollectionView.frame.size.width / 3 - 1, height: profileCollectionView.frame.size.width / 3 - 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

