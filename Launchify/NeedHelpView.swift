//
//  NeedHelpView.swift
//  Launchify
//
//  Created by Clay Ellis on 4/8/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//

import UIKit

class NeedHelpView: UIView {
    
    // Subviews
    let label = UILabel()
    let logoutButton = UIButton()
    
    
    // MARK: - Initialization
    convenience init() {
        self.init(frame: .zero)
        configureSubviews()
        configureLayout()
    }
    
    func configureSubviews() {
        // Add Subviews
        addSubview(label)
        addSubview(logoutButton)
        
        // Style View
        
        
        // Style Subviews
        label.text = "Need Help? View"
        
        logoutButton.setTitle("Logout", forState: .Normal)
        logoutButton.setTitleColor(.whiteColor(), forState: .Normal)
        logoutButton.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
    }
    
    func configureLayout() {
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(label, logoutButton)
        
        // Add Constraints
        NSLayoutConstraint.activateConstraints([
            label.centerXAnchor.constraintEqualToAnchor(centerXAnchor),
            label.centerYAnchor.constraintEqualToAnchor(centerYAnchor),
            
            logoutButton.centerXAnchor.constraintEqualToAnchor(centerXAnchor),
            logoutButton.bottomAnchor.constraintEqualToAnchor(bottomAnchor, constant: -15)
            ])
    }
    
}
