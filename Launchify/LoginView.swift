//
//  LoginView.swift
//  Launchify
//
//  Created by Clay Ellis on 4/3/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//

import UIKit

class LoginView: UIView {
    
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
        backgroundColor = .lfMediumGray()
        
        // Style Subviews
        loginButton.setTitle("Login to Spotify", forState: .Normal)
        loginButton.setTitleColor(.whiteColor(), forState: .Normal)
    }
    
    func configureLayout() {
        setTranslatesAutoresizingMaskIntoConstraintsToFalse([loginButton])
        
        // Add Constraints
        loginButton.fillSuperview()
    }
    
}