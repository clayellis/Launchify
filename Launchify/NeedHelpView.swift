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
    
    
    // MARK: - Initialization
    convenience init() {
        self.init(frame: .zero)
        configureSubviews()
        configureLayout()
    }
    
    func configureSubviews() {
        // Add Subviews
        addSubview(label)
        
        // Style View
        
        
        // Style Subviews
        label.text = "Need Help? View"
    }
    
    func configureLayout() {
        setTranslatesAutoresizingMaskIntoConstraintsToFalse([label])
        
        // Add Constraints
        NSLayoutConstraint.activateConstraints([
            // Label
            label.centerXAnchor.constraintEqualToAnchor(centerXAnchor),
            label.centerYAnchor.constraintEqualToAnchor(centerYAnchor)
            ])
    }
    
}
