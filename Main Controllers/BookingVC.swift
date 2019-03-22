//
//  BookingVC.swift
//  StudioSeshApp
//
//  Created by James B Morris on 1/15/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics
import Braintree
import BraintreeDropIn

class BookingVC: UIViewController {
    
    @IBOutlet weak var closeBtn: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var venueLabel: UILabel!
    
    @IBOutlet weak var perksLabel: UILabel!
    
    @IBOutlet weak var fromDateView: UIView!
    
    @IBOutlet weak var fromDateLabel: UILabel!
    
    @IBOutlet weak var toDateView: UIView!
    
    @IBOutlet weak var toDateLabel: UILabel!
    
    @IBOutlet weak var selectPaymentMethodBtn: UIButton!
    
    var post: Posts!
    var user: User!
    var price: String!
    var date1: String?
    var date2: String?
    
    func initData(forVenue venue: User, forPost post: Posts, forPrice price: String) {
        self.user = venue
        self.post = post
        self.price = price
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(price)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "FirstDate"), object: nil, queue: .main) { (notification) in
            guard let dict = notification.userInfo else{
                return
            }
            guard let date = dict["date"] as? Date else{
                return
            }
            self.date1 = date.string
            self.fromDateLabel.text = date.string
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "SecondDate"), object: nil, queue: .main) { (notification) in
            guard let dict = notification.userInfo else{
                return
            }
            guard let date = dict["date"] as? Date else{
                return
            }
            self.date2 = date.string
            self.toDateLabel.text = date.string
        }
        
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(goToCalendar))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(goToCalendar))
        
        self.fromDateView.addGestureRecognizer(tapGesture1)
        self.toDateView.addGestureRecognizer(tapGesture2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.titleLabel.text = "Book \(user.username!)"
        self.venueLabel.text = user.username!
        self.perksLabel.text = post.perks!
    }
    
    @IBAction func closeBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectPaymentMethodBtnWasPressed(_ sender: Any) {
        ProgressHUD.show("Please give us a moment to connect to our servers...", interaction: false)
        
        fetchClientToken()
    }
    
    func fetchClientToken() {
        // TODO: Switch this URL to your own authenticated API
        let clientTokenURL = NSURL(string: "https://studiosesh.herokuapp.com/client_token")!
        let clientTokenRequest = NSMutableURLRequest(url: clientTokenURL as URL)
        clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: clientTokenRequest as URLRequest) { (data, response, error) -> Void in
            // TODO: Handle errors
            if error != nil {
                print("ERROR OCCURRED!")
                ProgressHUD.showError("Whoops! There was an issue. Please try again.")
            } else { print("Success!") }
            
            let clientToken = String(data: data!, encoding: String.Encoding.utf8)
            //print("CLIENT TOKEN: \(clientToken!)")
            
            // As an example, you may wish to present Drop-in at this point.
            ProgressHUD.showSuccess("Done!")
            self.showDropIn(clientTokenOrTokenizationKey: clientToken!)
            
            }.resume()
    }
    
    func showDropIn(clientTokenOrTokenizationKey: String) {
        let request =  BTDropInRequest()
        let numberAmount = Float(price.removeFormatAmount())
        request.amount = "\(numberAmount)"
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
        { (controller, result, error) in
            if (error != nil) {
                print("ERROR")
            } else if (result?.isCancelled == true) {
                print("CANCELLED")
            } else if let result = result {
                // Use the BTDropInResult properties to update your UI
                print("Type: \(result.paymentOptionType)")
                print("Method: \(result.paymentMethod!)")
                print("Icon: \(result.paymentIcon)")
                print("Description: \(result.paymentDescription)")
                print("Amount: \(request.amount)")
                
                self.postNonceToServer(paymentMethodNonce: (result.paymentMethod?.nonce)!)
            }
            controller.dismiss(animated: true, completion: nil)
            self.goToConfirmBooking()
        }
        self.present(dropIn!, animated: true, completion: nil)
    }
    
    func postNonceToServer(paymentMethodNonce: String) {
        // Update URL with your server
        let paymentURL = URL(string: "https://studiosesh.herokuapp.com/checkouts")!
        let numberAmount = Float(price.removeFormatAmount())
        var request = URLRequest(url: paymentURL)
        request.httpBody = "payment_method_nonce=\(paymentMethodNonce)&amount=\(numberAmount) ".data(using: String.Encoding.utf8)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            // TODO: Handle success or failure
            if (error != nil) {
                print("Error: \(error?.localizedDescription)")
            } else {
                print("Success!")
            }
            }.resume()
    }
    
    @objc func goToCalendar(_ sender:UITapGestureRecognizer) {
        let calendarVC = storyboard?.instantiateViewController(withIdentifier: "CalendarVC") as! CalendarVC
        calendarVC.isFirstDate = sender.view == fromDateView
        present(calendarVC, animated: true, completion: nil)
    }
    
    func goToConfirmBooking() {
        let confirmBookingVC = storyboard?.instantiateViewController(withIdentifier: "ConfirmBookingVC") as! ConfirmBookingVC
        confirmBookingVC.initData(forVenue: self.user, forPost: self.post, forPrice: self.post.price!, forDate1: self.date1!, forDate2: self.date2!)
        present(confirmBookingVC, animated: true, completion: nil)
    }
    
    
   

}

extension String {
    func removeFormatAmount() -> Double {
        let formatter = NumberFormatter()
        
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.decimalSeparator = ","
        
        return formatter.number(from: self) as! Double? ?? 0
    }
}
