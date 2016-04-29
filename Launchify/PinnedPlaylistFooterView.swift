//
//  PinnedPlaylistFooterView.swift
//  Launchify
//
//  Created by Clay Ellis on 4/9/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//

import UIKit

class PinnedPlaylistFooterView: UITableViewHeaderFooterView {
    
    // Reuse Identifier
    static let reuseIdentifier = "PINNED_FOOTER"
    
    // Subviews
    let topSeparator = UIView()
    let pinnedHandle = UIImageView()
    
    // Images
    let flatImage_Normal = UIImage(named: "PinnedHandle_Normal")
    let flatImage_Highlighted = UIImage(named: "PinnedHandle_Highlighted")
    
    // MARK: - Initialization
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureSubviews()
        configureLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration Methods
    func configureSubviews() {
        // Add Subviews
        contentView.addSubview(pinnedHandle)
        addSubview(topSeparator)
        
        // Style View
        contentView.backgroundColor = .lfDarkGray()
        
        // Style Subviews
        topSeparator.backgroundColor = .lfSeparatorPinnedGray()
        
        pinnedHandle.image = flatImage_Normal
        pinnedHandle.contentMode = .Center
    }
    
    func configureLayout() {
        setTranslatesAutoresizingMaskIntoConstraintsToFalse([topSeparator, pinnedHandle])
        
        // Add Constraints
        NSLayoutConstraint.activateConstraints([
            topSeparator.leftAnchor.constraintEqualToAnchor(leftAnchor),
            topSeparator.rightAnchor.constraintEqualToAnchor(rightAnchor),
            topSeparator.topAnchor.constraintEqualToAnchor(topAnchor, constant: -0.2),
            topSeparator.heightAnchor.constraintEqualToConstant(0.7)
            ])
        
        pinnedHandle.fillSuperview()
    }

    func adjustImageToState(state: UIControlState) {
        UIView.transitionWithView(pinnedHandle, duration: 0.2, options: [.BeginFromCurrentState, .TransitionCrossDissolve], animations: {
            if state == .Highlighted {
                self.pinnedHandle.image = self.flatImage_Highlighted
            } else {
                self.pinnedHandle.image = self.flatImage_Normal
            }
            }, completion: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        adjustImageToState(.Highlighted)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        adjustImageToState(.Normal)
    }
}

