//
//  LoadingView.swift
//  Launchify
//
//  Created by Clay Ellis on 4/21/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    
    // Subviews
    let loadingLabel = UILabel()
    
    
    // MARK: - Initialization
    convenience init() {
        self.init(frame: .zero)
        configureSubviews()
        configureLayout()
    }
    
    func configureSubviews() {
        // Add Subviews
        addSubview(loadingLabel)
        
        // Style View
        backgroundColor = .lfMediumGray()
        
        // Style Subviews
        loadingLabel.text = "Loading..."
        loadingLabel.textColor = .whiteColor()
        loadingLabel.textAlignment = .Center
    }
    
    func configureLayout() {
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(loadingLabel)
        
        // Add Constraints
        loadingLabel.fillSuperview()
    }
    
}
