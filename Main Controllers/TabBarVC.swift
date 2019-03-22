//
//  TabBarVC.swift
//  StudioSeshApp
//
//  Created by James B Morris on 1/6/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit

class TabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(forName: NSNotification.Name.init("newMessage"), object: nil, queue: OperationQueue.main) { (notification) in
            self.selectedIndex = 1
            let user = notification.userInfo!["message"] as! User
            DispatchQueue.global().asyncAfter(deadline: .now()+0.5, execute: {
                NotificationCenter.default.post(name: NSNotification.Name.init("CreateMessage"), object: nil, userInfo: [
                    "message":user
                    ])
            })
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
