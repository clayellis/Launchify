//
//  PinnedExplanationView.swift
//  Launchify
//
//  Created by Clay Ellis on 4/19/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//

import UIKit

class PinnedExplanationView: UIView {
    
    // Subviews
    let explanationContainer = UIStackView()
    let explanationPrefixLabel = UILabel()
    let toggleButton = UIButton()
    let explanationSuffixLabel = UILabel()
    
    // MARK: - Initialization
    convenience init() {
        self.init(frame: .zero)
        configureSubviews()
        configureLayout()
    }
    
    func configureSubviews() {
        // Add Subviews
        addSubview(explanationContainer)
        explanationContainer.addArrangedSubview(explanationPrefixLabel)
        explanationContainer.addArrangedSubview(toggleButton)
        explanationContainer.addArrangedSubview(explanationSuffixLabel)
        
        // Style Subviews
        explanationContainer.backgroundColor = .blackColor()
        explanationContainer.axis = .Horizontal
        explanationContainer.alignment = .Center
        explanationContainer.spacing = 9
        explanationContainer.distribution = .FillProportionally
        
        explanationPrefixLabel.text = "Tap"
        explanationPrefixLabel.textColor = .whiteColor()
        explanationPrefixLabel.font = .systemFontOfSize(18)
        
        toggleButton.setImage(UIImage(named: "Toggle_Unpinned_Normal")!, forState: .Normal)
        toggleButton.setImage(UIImage(named: "Toggle_Unpinned_Highlighted")!, forState: .Highlighted)
        toggleButton.setImage(UIImage(named: "Toggle_Pinned_Normal")!, forState: .Selected)
        toggleButton.addTarget(self, action: #selector(toggleButtonTapped), forControlEvents: .TouchUpInside)
        
        explanationSuffixLabel.text = "to pin a playlist"
        explanationSuffixLabel.textColor = explanationPrefixLabel.textColor
        explanationSuffixLabel.font = explanationPrefixLabel.font
    }
    
    func configureLayout() {
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(explanationContainer, explanationPrefixLabel, toggleButton, explanationSuffixLabel)
        
        // Add Constraints
        NSLayoutConstraint.activateConstraints([
            explanationContainer.centerXAnchor.constraintEqualToAnchor(centerXAnchor),
            explanationContainer.centerYAnchor.constraintEqualToAnchor(centerYAnchor),
        ])
    }
    
    // MARK: Animation Methods
    // -----------------------------------------------------------------------------------------------------------------------------------------v
    func toggleButtonTapped() {
        toggleButton.selected = true
        
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delay, dispatch_get_main_queue()) {
            UIView.transitionWithView(self.toggleButton, duration: 0.5, options: [.BeginFromCurrentState, .TransitionCrossDissolve], animations: {
                self.toggleButton.selected = false
                }, completion: {
                    _ in
            })
        }
    }
    // -----------------------------------------------------------------------------------------------------------------------------------------^
}