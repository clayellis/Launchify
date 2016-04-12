//
//  MainView.swift
//  Launchify
//
//  Created by Clay Ellis on 4/3/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//

import UIKit

class MainView: UIView {
    
    // Subviews
    let loginButton = UIButton()
    
    
    convenience init() {
        self.init(frame: .zero)
        configureSubviews()
        configureLayout()
    }
    
    func configureSubviews() {
        // Add Subviews
        addSubview(loginButton)
        
        // Style View
        backgroundColor = UIColor(red:0.15, green:0.15, blue:0.15, alpha:1.00)
        
        // Style Subviews
        loginButton.setTitle("Login to Spotify", forState: .Normal)
        loginButton.setTitleColor(.whiteColor(), forState: .Normal)
    }
    
    func configureLayout() {
        setTranslatesAutoresizingMaskIntoConstraintsToFalse([loginButton])
        
        // Add Constraints
        NSLayoutConstraint.activateConstraints([
            // Login Button
            loginButton.centerXAnchor.constraintEqualToAnchor(centerXAnchor),
            loginButton.centerYAnchor.constraintEqualToAnchor(centerYAnchor)
            ])
    }
    
}