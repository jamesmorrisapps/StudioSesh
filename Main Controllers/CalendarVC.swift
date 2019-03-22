//
//  CalendarVC.swift
//  StudioSeshApp
//
//  Created by James B Morris on 7/25/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import UIKit
import FSCalendar

class CalendarVC: UIViewController {
    
    @IBOutlet weak var calendar: FSCalendar!
    
    var firstDate: Date?{
        didSet{
            guard let date = firstDate else{
                return
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FirstDate"), object: nil, userInfo: ["date":date])
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    var secondDate: Date?{
        didSet{
            guard let date = secondDate else{
                return
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SecondDate"), object: nil, userInfo: ["date":date])
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    var isFirstDate:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        calendar.delegate = self
        
        
    }


}

extension CalendarVC: FSCalendarDelegate{
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if isFirstDate {
            firstDate = date
        }else{
            secondDate = date
        }
    }
}
