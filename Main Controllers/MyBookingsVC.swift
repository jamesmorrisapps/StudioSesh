//
//  MyBookingsVC.swift
//  StudioSeshApp
//
//  Created by James B Morris on 2/17/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit

class MyBookingsVC: UIViewController {
    
    @IBOutlet weak var closeBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    //var userId: String?
    //var currentUser: User?
    
    var bookings = [Booking]()
    var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        bookings = []
        users = []
        loadBookings()
        tableView.reloadData()
    }
    
    func loadBookings() {
        API.User.observeCurrentUser { (user) in
    
            if user.persona == "Venue" {
            
            API.Venue_Booking.REF_VENUE_BOOKINGS.child(user.id!).observe(.childAdded) { (snapshotBooking) in
                
            API.Bookings.observeBookings(withUserId: snapshotBooking.key, completion: { (booking) in
                
                    self.fetchUser(uid: booking.uid!, completed: {
                        DispatchQueue.main.async {
                            self.bookings.append(booking)
                            print(booking)
                            self.tableView.reloadData()
                        }
                    })
                    })
                }
            } else if user.persona == "Artist" {
                
                API.User_Booking.REF_USER_BOOKINGS.child((API.User.CURRENT_USER?.uid)!).observe(.childAdded, with: { (snapshotBooking) in
                    
                    API.Bookings.observeBookings(withUserId: snapshotBooking.key, completion: { (booking) in
                        self.fetchUser(uid: booking.id!, completed: {
                            DispatchQueue.main.async {
                                self.bookings.append(booking)
                                print(booking)
                                self.tableView.reloadData()
                            }
                        })
                    })
                })
            } else {
                print("ERROR ERROR ERROR")
                return
            }
            }
        }
    
    func fetchUser(uid: String, completed: @escaping () -> Void) {
        
        API.User.observeUsers(withId: uid) { (user) in
            self.users.append(user)
            print(user)
            completed()
        }
    }
    
    @IBAction func closeBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

}

extension MyBookingsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if bookings.count == 0 {
            tableView.setEmptyView(title: "No bookings yet.", message: "Tap a venue post in your feed to book a venue!", image: #imageLiteral(resourceName: "booking-Icon"))
        }
        else {
            tableView.restore()
        }
        return bookings.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if users[indexPath.row].persona == "Venue" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userBookingCell", for: indexPath) as! UserBookingCell
            
            let booking = bookings[indexPath.row]
            let user = users[indexPath.row]
            cell.booking = booking
            cell.user = user
            return cell
        } else if users[indexPath.row].persona == "Artist" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "venueBookingCell", for: indexPath) as! VenueBookingCell
            
            let booking = bookings[indexPath.row]
            let user = users[indexPath.row]
            cell.booking = booking
            cell.user = user
            return cell
        } else {
            print("ERROR ERROR ERROR")
            return UITableViewCell()
        }
    }
}
