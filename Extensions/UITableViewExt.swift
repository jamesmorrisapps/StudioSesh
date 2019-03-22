//
//  UITableViewExt.swift
//  StudioSeshApp
//
//  Created by James B Morris on 2/19/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit

extension UITableView {
    
    func setEmptyView(title: String, message: String, image: UIImage) {
        
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        let imageDisplayed = UIImageView()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        imageDisplayed.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = #colorLiteral(red: 0, green: 0.5650748014, blue: 0.3169043064, alpha: 1)
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        messageLabel.textColor = UIColor.lightGray
        messageLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        emptyView.addSubview(imageDisplayed)
        imageDisplayed.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        imageDisplayed.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 0).isActive = true
        imageDisplayed.widthAnchor.constraint(equalToConstant: 150).isActive = true
        imageDisplayed.heightAnchor.constraint(equalToConstant: 150).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        titleLabel.text = title
        messageLabel.text = message
        imageDisplayed.image = image
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        
        // The only tricky part is here:
        self.backgroundView = emptyView
        self.separatorStyle = .none
        
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
    
    func setEmptyViewSessions(title: String, message: String, image: UIImage) {
        
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        let imageDisplayed = UIImageView()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        imageDisplayed.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = #colorLiteral(red: 0.7230856579, green: 1, blue: 0.7462328794, alpha: 1)
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        messageLabel.textColor = UIColor.white
        messageLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        emptyView.addSubview(imageDisplayed)
        imageDisplayed.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        imageDisplayed.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 0).isActive = true
        imageDisplayed.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -50)
        imageDisplayed.widthAnchor.constraint(equalToConstant: 150).isActive = true
        imageDisplayed.heightAnchor.constraint(equalToConstant: 150).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor, constant: -23).isActive = true
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -70).isActive = true
        titleLabel.text = title
        messageLabel.text = message
        imageDisplayed.image = image
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        
        // The only tricky part is here:
        self.backgroundView = emptyView
        self.separatorStyle = .none
        
    }
    
}
