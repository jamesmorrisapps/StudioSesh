//
//  Date_Extension.swift
//  StudioSeshApp
//
//  Created by James B Morris on 1/27/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import Foundation

extension Date {
    
    var string:String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd yyyy"
        return formatter.string(from: self) 
    }
    
}
