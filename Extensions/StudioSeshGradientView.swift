//
//  StudioSeshGradientView.swift
//  StudioSeshApp
//
//  Created by James B Morris on 7/26/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import UIKit
@IBDesignable


class StudioSeshGradientView: UIView {
    
    @IBInspectable var topColor: UIColor = UIColor.gray {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var bottomColor: UIColor = UIColor.white {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.frame = self.bounds
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}
