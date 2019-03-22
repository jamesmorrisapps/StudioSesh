//
//  MakeReviewVC.swift
//  StudioSeshApp
//
//  Created by James B Morris on 1/3/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

class MakeReviewVC: UIViewController {
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var locationSlider: UISlider!

    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var arrivalSlider: UISlider!
    
    @IBOutlet weak var arrivalLabel: UILabel!
    
    @IBOutlet weak var neatnessSlider: UISlider!
    
    @IBOutlet weak var neatnessLabel: UILabel!
    
    @IBOutlet weak var qualitySlider: UISlider!
    
    @IBOutlet weak var qualityLabel: UILabel!
    
    @IBOutlet weak var professionalismSlider: UISlider!
    
    @IBOutlet weak var professionalismLabel: UILabel!
    
    @IBOutlet weak var constrainToBottom: NSLayoutConstraint!
    
    @IBOutlet weak var tableviewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var reviewView: UIView!
    
    @IBOutlet weak var reviewTextfield: UITextField!
    
    @IBOutlet weak var sendBtn: UIButton!
    
    @IBOutlet weak var backBtn: UIButton!
    
    var userId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        //reviewView.bindToKeyboard()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        UIView.animate(withDuration: 0.3) {
            self.constrainToBottom.constant = -(keyboardFrame?.height)!
            self.tableviewBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }

    @objc func keyboardWillHide(_ notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.constrainToBottom.constant = 0
            self.tableviewBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func handleTextField() {
        reviewTextfield.addTarget(self, action: #selector(MakeReviewVC.textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    @objc func textFieldDidChange() {
        if let reviewText = reviewTextfield.text, !reviewText.isEmpty {
            sendBtn.setTitleColor(UIColor.green, for: .normal)
            sendBtn.isEnabled = true
            return
        }
        sendBtn.setTitleColor(UIColor.lightGray, for: .normal)
        sendBtn.isEnabled = false
    }
    
    func empty() {
        self.reviewTextfield.text = ""
        sendBtn.setTitleColor(UIColor.lightGray, for: .normal)
        sendBtn.isEnabled = false
    }
    
    @IBAction func locationSliderValueChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        locationLabel.text = "\(currentValue)"
    }
    
    @IBAction func arrivalSliderValueChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        arrivalLabel.text = "\(currentValue)"
    }
    
    @IBAction func neatnessSliderValueChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        neatnessLabel.text = "\(currentValue)"
    }
    
    @IBAction func qualitySliderValueChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        qualityLabel.text = "\(currentValue)"
    }
    
    @IBAction func professionalismSliderValueChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        professionalismLabel.text = "\(currentValue)"
    }

    @IBAction func sendBtnWasPressed(_ sender: Any) {
        if reviewTextfield.text != "" {
            reviewTextfield.isEnabled = false
            sendBtn.isEnabled = false
            
            let reviewsReference = API.Reviews.REF_REVIEWS
            let newReviewId = reviewsReference.childByAutoId().key
            let newReviewReference = reviewsReference.child(newReviewId)
            guard let currentUser = Auth.auth().currentUser else {
                return
            }
            let currentUserId = currentUser.uid
            let locationValue: Int = Int(locationLabel.text!)!
            let arrivalValue: Int = Int(arrivalLabel.text!)!
            let neatnessValue: Int = Int(neatnessLabel.text!)!
            let qualityValue: Int = Int(qualityLabel.text!)!
            let professionalismValue: Int = Int(professionalismLabel.text!)!
            let reviewSum = locationValue + arrivalValue + neatnessValue + qualityValue + professionalismValue
            let reviewAverage = reviewSum / 5
            
            newReviewReference.setValue((["reviewText" : reviewTextfield.text!, "locationRating" : locationValue, "arrivalRating" : arrivalValue, "neatnessRating" : neatnessValue, "qualityRating" : qualityValue, "professionalismRating" : professionalismValue, "reviewPercentage" : reviewAverage, "uid" : currentUserId])) { (error, ref) in
                if error != nil {
                    ProgressHUD.showError("Whoops! There was an issue. Please try again.")
                    return
                }
                
                let userReviewRef = API.User_Review.REF_USER_REVIEWS.child(self.userId).child(newReviewId)
                userReviewRef.setValue(true, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        ProgressHUD.showError("Whoops! There was an issue. Please try again.")
                        return
                    }
                })
                self.reviewTextfield.text = ""
                self.reviewTextfield.isEnabled = true
                self.sendBtn.isEnabled = true
                
                let timestamp = Int(Date().timeIntervalSince1970)
                API.Follow.REF_FOLLOWERS.child(API.User.CURRENT_USER!.uid).observe(.value, with: { (snapshot) in
                    let arraySnapshot = snapshot.children.allObjects as! [DataSnapshot]
                    arraySnapshot.forEach({ (child) in
                        API.User_Review.REF_USER_REVIEWS.child(child.key).updateChildValues(["\(newReviewId)" : true])
                        let newNotificationId = API.Notification.REF_NOTIFICATIONS.child(child.key).childByAutoId().key
                        let newNotificationReference = API.Notification.REF_NOTIFICATIONS.child(child.key).child(newNotificationId)
                        newNotificationReference.setValue(["from" : API.User.CURRENT_USER!.uid, "type" : "review", "objectId" : self.userId, "timestamp" : timestamp])
                    })
                })
                
                self.dismiss(animated: true, completion: nil)
        }
        }
    }
    
    @IBAction func backBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
