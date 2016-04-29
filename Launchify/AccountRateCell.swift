//
//  AccountRateCell.swift
//  Launchify
//
//  Created by Clay Ellis on 4/24/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//


import UIKit

class AccountRateCell: UITableViewCell {
    
    // Reuse Identifier
    static let reuseIdentifier = "ACCOUNT_RATE"
    
    // Subviews
    let topSeparator = UIView()
    let starsImageView = UIImageView()
    
    
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
        contentView.addSubview(topSeparator)
        contentView.addSubview(starsImageView)
        
        // Style View
        preservesSuperviewLayoutMargins = false
        layoutMargins = UIEdgeInsetsZero
        separatorInset = UIEdgeInsetsZero
        contentView.backgroundColor = .lfDarkGray()
        backgroundColor = contentView.backgroundColor
//        selectionStyle = .None
        
        // Style Subviews
        topSeparator.backgroundColor = .lfSeparatorGray()
        
        starsImageView.image = UIImage(named: "Stars")
        starsImageView.contentMode = .Center
    }
    
    func configureLayout() {
        setTranslatesAutoresizingMaskIntoConstraintsToFalse([topSeparator, starsImageView])
        
        // Add Constraints
        NSLayoutConstraint.activateConstraints([
            topSeparator.leftAnchor.constraintEqualToAnchor(contentView.leftAnchor),
            topSeparator.rightAnchor.constraintEqualToAnchor(contentView.rightAnchor),
            topSeparator.topAnchor.constraintEqualToAnchor(contentView.topAnchor),
            topSeparator.heightAnchor.constraintEqualToConstant(0.7),
            
            starsImageView.centerXAnchor.constraintEqualToAnchor(contentView.centerXAnchor),
            starsImageView.topAnchor.constraintEqualToAnchor(topSeparator.bottomAnchor, constant: 15),
            starsImageView.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor, constant: -15)
            ])
    }
    // -----------------------------------------------------------------------------------------------------------------------------------------^
}
