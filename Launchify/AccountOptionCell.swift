//
//  AccountOptionCell.swift
//  Launchify
//
//  Created by Clay Ellis on 4/24/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//


import UIKit

class AccountOptionCell: UITableViewCell {
    
    // Reuse Identifier
    static let reuseIdentifier = "ACCOUNT_OPTION"
    
    // Subviews
    
    
    // MARK: - Initialization
    // -----------------------------------------------------------------------------------------------------------------------------------------v
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSubviews()
        configureLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // -----------------------------------------------------------------------------------------------------------------------------------------^
    
    // MARK: Configuration
    // -----------------------------------------------------------------------------------------------------------------------------------------v
    func configureSubviews() {
        // Add Subviews
        
        
        // Style View
        preservesSuperviewLayoutMargins = false
        layoutMargins = UIEdgeInsetsZero
        separatorInset = UIEdgeInsetsZero
        contentView.backgroundColor = .lfDarkGray()
        backgroundColor = contentView.backgroundColor
        let viewForSelectedBackgroundView = UIView()
        viewForSelectedBackgroundView.backgroundColor = .lfDarkestGray()
        selectedBackgroundView = viewForSelectedBackgroundView
        
        // Style Subviews
        textLabel?.textColor = .whiteColor()
    }
    
    func configureLayout() {
        setTranslatesAutoresizingMaskIntoConstraintsToFalse([])
        
        // Add Constraints
        NSLayoutConstraint.activateConstraints([
            heightAnchor.constraintEqualToConstant(60)
            ])
    }
    // -----------------------------------------------------------------------------------------------------------------------------------------^
}
