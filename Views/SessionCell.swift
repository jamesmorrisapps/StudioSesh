//
//  SessionCell.swift
//  StudioSeshApp
//
//  Created by James B Morris on 12/27/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import UIKit

class SessionCell: UITableViewCell {
    
    @IBOutlet weak var sessionTitleLabel: UILabel!
    
    @IBOutlet weak var sessionDescriptionLabel: UILabel!
    
    @IBOutlet weak var sessionMemberLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configureCell(title: String, description: String, memberCount: Int) {
        self.sessionTitleLabel.text = title
        self.sessionDescriptionLabel.text = description
        self.sessionMemberLabel.text = "\(memberCount) members."
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
