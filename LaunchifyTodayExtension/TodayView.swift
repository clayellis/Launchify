//
//  TodayView.swift
//  Launchify
//
//  Created by Clay Ellis on 4/3/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//

import UIKit

class TodayView: UIView {
    
    // Subviews
    let playlistTableView = UITableView()
    
    
    // MARK: - Initialization
    convenience init() {
        self.init(frame: .zero)
        configureSubviews()
        configureLayout()
    }
    
    func configureSubviews() {
        // Add Subviews
        addSubview(playlistTableView)
        
        // Style View
        
        
        // Style Subviews
        
    }
    
    func configureLayout() {
        setTranslatesAutoresizingMaskIntoConstraintsToFalse([playlistTableView])
        
        // Add Constraints
        NSLayoutConstraint.activateConstraints([
            playlistTableView.leftAnchor.constraintEqualToAnchor(leftAnchor),
            playlistTableView.rightAnchor.constraintEqualToAnchor(rightAnchor),
            playlistTableView.topAnchor.constraintEqualToAnchor(topAnchor),
            playlistTableView.bottomAnchor.constraintEqualToAnchor(bottomAnchor)
            ])
    }
    
}
