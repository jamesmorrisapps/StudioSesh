//
//  ButtonExtension.swift
//  StudioSeshApp
//
//  Created by James B Morris on 7/26/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import UIKit

extension UIButton {
    func wiggle(){
        let wiggleAnim = CABasicAnimation(keyPath: "position")
        wiggleAnim.duration = 0.05
        wiggleAnim.repeatCount = 5
        wiggleAnim.autoreverses = true
        wiggleAnim.fromValue = CGPoint(x: self.center.x - 4.0, y: self.center.y)
        wiggleAnim.toValue = CGPoint(x: self.center.x + 4.0, y: self.center.y)
        layer.add(wiggleAnim, forKey: "position")
    }
}
