//
//  ReviewsVC.swift
//  StudioSeshApp
//
//  Created by James B Morris on 1/2/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

protocol ReviewsVCDelegate {
    func goToMakeReviewsVC(userId: String)
}

class ReviewsVC: UIViewController {
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var makeReviewBtn: UIButton!
    
    @IBOutlet weak var locationBar: UIView!
    
    @IBOutlet weak var locationContainerView: UIView!
    
    @IBOutlet weak var locationPercentLabel: UILabel!
    
    @IBOutlet weak var locationConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var arrivalBar: UIView!
    
    @IBOutlet weak var arrivalContainerView: UIView!
    
    @IBOutlet weak var arrivalPercentLabel: UILabel!
    
    @IBOutlet weak var arrivalConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var neatnessBar: UIView!
    
    @IBOutlet weak var neatnessContainerView: UIView!
    
    @IBOutlet weak var neatnessPercentLabel: UILabel!
    
    @IBOutlet weak var neatnessConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var qualityBar: UIView!
    
    @IBOutlet weak var qualityContainerView: UIView!
    
    @IBOutlet weak var qualityPercentLabel: UILabel!
    
    @IBOutlet weak var qualityConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var professionalismBar: UIView!
    
    @IBOutlet weak var professionalismContainerView: UIView!
    
    @IBOutlet weak var professionalismPercentLabel: UILabel!
    
    @IBOutlet weak var professionalismConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    
    var userId: String!
    
    var reviews = [Review]()
    var users = [User]()
    
    var locationAverages = [Int]()
    var arrivalAverages = [Int]()
    var neatnessAverages = [Int]()
    var qualityAverages = [Int]()
    var professionalismAverages = [Int]()
    
    var delegate: ReviewsVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationBar.frame.size.width = 0
        self.arrivalBar.frame.size.width = 0
        self.neatnessBar.frame.size.width = 0
        self.qualityBar.frame.size.width = 0
        self.professionalismBar.frame.size.width = 0
        
        if userId == Auth.auth().currentUser?.uid {
            self.makeReviewBtn.isHidden = true
        }

        tableView.dataSource = self
        tableView.delegate = self
        loadReviews()
        tableView.reloadData()
        loadGlobalReviews()
    }
    
    func loadReviews() {
        
//        API.Reviews.REF_REVIEWS.child(self.userId).observe(.childAdded) { (snapshotReview) in
//        print(snapshotReview)
//            
//        }
        
        API.User_Review.REF_USER_REVIEWS.child(self.userId).observe(.childAdded) { (snapshotReview) in
            print(snapshotReview)
            API.Reviews.observeReviews(withUserId: snapshotReview.key, completion: { (review) in
                self.fetchUser(uid: review.uid!, completed: {
                    DispatchQueue.main.async {
                        self.reviews.append(review)
                        self.tableView.reloadData()
                    }
                })
            })
        }
        
//        API.Reviews.observeReviews(withUserId: self.userId, completion: { (review) in
//            self.fetchUser(uid: review.uid!, completed: {
//                DispatchQueue.main.async {
//                    self.reviews.append(review)
//                    self.tableView.reloadData()
//                }
//            })
//        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "makeReviewVC" {
            let makeReviewVC = segue.destination as! MakeReviewVC
            let userId = self.userId
            makeReviewVC.userId = userId
        }
    }
    
    func fetchUser(uid: String, completed: @escaping () -> Void) {
        
        API.User.observeUsers(withId: uid) { (user) in
            self.users.append(user)
            completed()
        }
    }
    
    func loadGlobalReviews() {
        
        API.User_Review.REF_USER_REVIEWS.child(self.userId).observe(.childAdded) { (snapshotReview) in
            
            API.Reviews.observeReviews(withUserId: snapshotReview.key, completion: { (review) in
                self.fetchUser(uid: review.uid!, completed: {
                    DispatchQueue.main.async {
                        
                        self.locationAverages.append(review.locationRating!)
                        self.tableView.reloadData()
                        let sumLocation = self.locationAverages.reduce(0, +)
                        let avgLocation = sumLocation / self.locationAverages.count
                        self.locationPercentLabel.text = "\(avgLocation)%"
                        UIView.animate(withDuration: 1.7) {
                            self.locationConstraint.constant = CGFloat(Int(self.locationContainerView.frame.size.width) - (avgLocation * 4) + 30)
                        }
                        
                        self.arrivalAverages.append(review.arrivalRating!)
                        self.tableView.reloadData()
                        let sumArrival = self.arrivalAverages.reduce(0, +)
                        let avgArrival = sumArrival / self.arrivalAverages.count
                        self.arrivalPercentLabel.text = "\(avgArrival)%"
                        UIView.animate(withDuration: 1.7) {
                            self.arrivalConstraint.constant = CGFloat(Int(self.arrivalContainerView.frame.size.width) - (avgArrival * 4) + 30)
                        }
                        
                        self.neatnessAverages.append(review.neatnessRating!)
                        self.tableView.reloadData()
                        let sumNeatness = self.neatnessAverages.reduce(0, +)
                        let avgNeatness = sumNeatness / self.neatnessAverages.count
                        self.neatnessPercentLabel.text = "\(avgNeatness)%"
                        UIView.animate(withDuration: 1.7) {
                            self.neatnessConstraint.constant = CGFloat(Int(self.neatnessContainerView.frame.size.width) - (avgNeatness * 4) + 30)
                        }
                        
                        self.qualityAverages.append(review.qualityRating!)
                        self.tableView.reloadData()
                        let sumQuality = self.qualityAverages.reduce(0, +)
                        let avgQuality = sumQuality / self.qualityAverages.count
                        self.qualityPercentLabel.text = "\(avgQuality)%"
                        UIView.animate(withDuration: 1.7) {
                            self.qualityConstraint.constant = CGFloat(Int(self.qualityContainerView.frame.size.width) - (avgQuality * 4) + 30)
                        }
                        
                        self.professionalismAverages.append(review.professionalismRating!)
                        self.tableView.reloadData()
                        let sumProfessionalism = self.professionalismAverages.reduce(0, +)
                        let avgProfessionalism = sumProfessionalism / self.professionalismAverages.count
                        self.professionalismPercentLabel.text = "\(avgProfessionalism)%"
                        UIView.animate(withDuration: 1.7) {
                            self.professionalismConstraint.constant = CGFloat(Int(self.professionalismContainerView.frame.size.width) - (avgProfessionalism * 4) + 30)
                        }
                    }
                })
            })
        }
    }
    
    func goToMakeReviews() {
        if let id = self.userId {
            delegate?.goToMakeReviewsVC(userId: id)
        }
    }
    
    @IBAction func backBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func makeReviewBtnWasPressed(_ sender: Any) {
        goToMakeReviews()
    }
    
    

}

extension ReviewsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if reviews.count == 0 {
            tableView.setEmptyView(title: "No reviews yet.", message: "Reviews will appear here.", image: #imageLiteral(resourceName: "reviews-icon"))
        }
        else {
            tableView.restore()
        }
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ReviewCell
        let review = reviews[indexPath.row]
        let user = users[indexPath.row]
        cell.review = review
        cell.user = user
        print(user.username)
        return cell
    }
}

extension ReviewsVC: ReviewsVCDelegate {
    func goToMakeReviewsVC(userId: String) {
        performSegue(withIdentifier: "makeReviewVC", sender: userId)
    }
}
