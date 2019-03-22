//
//  ConfirmBookingVC.swift
//  StudioSeshApp
//
//  Created by James B Morris on 2/12/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

class ConfirmBookingVC: UIViewController {
    
    @IBOutlet weak var closeBtn: UIButton!
    
    @IBOutlet weak var venueNameLabel: UILabel!
    
    @IBOutlet weak var confirmationNumberLabel: UILabel!
    
    @IBOutlet weak var checkinDateLabel: UILabel!
    
    @IBOutlet weak var checkoutDateLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var confirmBookingBtn: UIButton!
    
    @IBOutlet weak var cancelBookingBtn: UIButton!
    
    var post: Posts!
    var user: User!
    var price: String!
    var checkinDate: String?
    var checkoutDate: String?
    var ids: [String]?
    var booking: Booking?
    
    func initData(forVenue venue: User, forPost post: Posts, forPrice price: String, forDate1 date1: String, forDate2 date2: String) {
        self.user = venue
        self.post = post
        self.price = price
        self.checkinDate = date1
        self.checkoutDate = date2
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.ids = []
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.venueNameLabel.text = user.username!
        self.confirmationNumberLabel.text = String.random()
        self.checkinDateLabel.text = checkinDate
        self.checkoutDateLabel.text = checkoutDate
        self.priceLabel.text = price
    }
    
    @IBAction func closeBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmBookingBtnWasPressed(_ sender: Any) {
        
        confirmBookingBtn.isEnabled = false
        
        let bookingsReference = API.Bookings.REF_BOOKINGS
        let newBookingId = bookingsReference.childByAutoId().key
        let newBookingReference = bookingsReference.child(newBookingId)
        let id = user.id
        let confirmationNumber = confirmationNumberLabel.text!
        let checkinDateValue = checkinDateLabel.text!
        let checkoutDateValue = checkoutDateLabel.text!
        let priceValue = priceLabel.text!
        ids?.insert(id!, at: 0)
        print(id!)
        ids?.append((API.User.CURRENT_USER?.uid)!)
        print(ids!)
        
        newBookingReference.setValue((["id" : id!, "members" : self.ids!, "confirmationNumber" : confirmationNumber, "checkinDate" : checkinDateValue, "checkoutDate" : checkoutDateValue, "price" : priceValue, "uid" : API.User.CURRENT_USER!.uid])) { (error, ref) in
            if error != nil {
                ProgressHUD.showError("Whoops! There was an issue. Please try again.")
                return
            }
        }
        let timestamp = Int(Date().timeIntervalSince1970)
//        API.Follow.REF_FOLLOWERS.child(API.User.CURRENT_USER!.uid).observe(.value, with: { (snapshot) in
//            let arraySnapshot = snapshot.children.allObjects as! [DataSnapshot]
//            arraySnapshot.forEach({ (child) in
        API.Venue_Booking.REF_VENUE_BOOKINGS.child(id!).updateChildValues(["\(newBookingId)" : true])
        API.User_Booking.REF_USER_BOOKINGS.child((API.User.CURRENT_USER?.uid)!).updateChildValues(["\(newBookingId)" : true])
//                let newNotificationId = API.Notification.REF_NOTIFICATIONS.child(child.key).childByAutoId().key
//                let newNotificationReference = API.Notification.REF_NOTIFICATIONS.child(child.key).child(newNotificationId)
//                newNotificationReference.setValue(["from" : API.User.CURRENT_USER!.uid, "type" : "booking", "objectId" : newBookingId, "timestamp" : timestamp])
 //           })
//        })
        
        let newNotificationId = API.Notification.REF_NOTIFICATIONS.child(id!).childByAutoId().key
        let newNotificationReference = API.Notification.REF_NOTIFICATIONS.child(id!).child(newNotificationId)
            newNotificationReference.setValue(["from" : API.User.CURRENT_USER!.uid, "type" : "booking", "objectId" : newBookingId, "timestamp" : timestamp])
        
            self.confirmBookingBtn.isEnabled = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let confirmDoneVC = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmDoneVC") as! ConfirmDoneVC
            self.present(confirmDoneVC, animated: true, completion: {
                confirmDoneVC.ximage.isHidden = true
                confirmDoneVC.checkBox.onAnimationType = .stroke
                confirmDoneVC.checkBox.on = true
                confirmDoneVC.displayMessage.text = "Thank you! Your booking is confirmed."
                confirmDoneVC.displayMessage.textColor = #colorLiteral(red: 0, green: 0.5650748014, blue: 0.3169043064, alpha: 1)
            })
        }
    }
    
    @IBAction func cancelBookingBtnWasPressed(_ sender: Any) {
        let confirmDoneVC = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmDoneVC") as! ConfirmDoneVC
        self.present(confirmDoneVC, animated: true, completion: {
            confirmDoneVC.checkBox.tintColor = #colorLiteral(red: 0.9993709922, green: 0.1453172863, blue: 0, alpha: 1)
            confirmDoneVC.checkBox.onCheckColor = #colorLiteral(red: 0.7086968591, green: 0.1060145378, blue: 0.006122987445, alpha: 1)
            confirmDoneVC.checkBox.hideBox = false
            confirmDoneVC.checkBox.on = false
            confirmDoneVC.checkBox.onAnimationType = .flat
            confirmDoneVC.ximage.isHidden = false
            confirmDoneVC.displayMessage.text = "Your booking has been canceled."
            confirmDoneVC.displayMessage.textColor = #colorLiteral(red: 0.9993709922, green: 0.1453172863, blue: 0, alpha: 1)
        })
    }
    
    

    
    
}

extension String {
    
    static func random(length: Int = 10) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""
        
        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
}
