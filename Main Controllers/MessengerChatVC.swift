//
//  MessengerChatVC.swift
//  StudioSeshApp
//
//  Created by James B Morris on 12/8/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics

class MessengerChatVC: UIViewController {

    @IBOutlet weak var menuBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController().revealToggle(_:)), for: .touchUpInside)
        self.view.addGestureRecognizer((self.revealViewController()?.panGestureRecognizer())!)
        self.view.addGestureRecognizer((self.revealViewController()?.tapGestureRecognizer())!)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init("CreateMessage"), object: nil, queue: OperationQueue.main) { (notification) in
            let user = notification.userInfo!["message"] as! User
            API.Sessions.createGroup(withTitle: user.username!, andDescription: "", forUserIds: [(Auth.auth().currentUser?.uid)!,user.id!], handler: { (groupCreated) in
                API.Sessions.getAllSessions { (returnedSessionsArray) in
                    for session in returnedSessionsArray {
                        print(session.title)
                        if session.title == user.username! {
                            guard let sessionFeedVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SessionFeedVC") as? SessionFeedVC else { return }
                            sessionFeedVC.initData(forSession: returnedSessionsArray.last!)
                            DispatchQueue.main.async {
                                self.present(sessionFeedVC, animated: true, completion: nil)
                            }
                            break
                        }
                    }
                }
            })
        }
    }
    
}

