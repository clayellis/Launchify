//
//  PagingView.swift
//  Launchify
//
//  Created by Clay Ellis on 4/4/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//

import UIKit

class PagingView: UIView {
    
    // Subviews
    let pagingController = LFPagingController()
    
    // MARK: - Initialization
    convenience init() {
        self.init(frame: .zero)
        configureSubviews()
        configureLayout()
    }
    
    func configureSubviews() {
        // Add Subviews
        addSubview(pagingController)
        
        // Style View
        backgroundColor = .lfDarkestGray()
        
        // Style Subviews
    }
    
    func configureLayout() {
        setTranslatesAutoresizingMaskIntoConstraintsToFalse([pagingController])
        
        // Add Constraints
        pagingController.fillSuperview()
    }
    
}
