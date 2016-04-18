//
//  UnpinnedTableHeaderView.swift
//  Launchify
//
//  Created by Clay Ellis on 4/16/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//

import UIKit


class UnpinnedTableHeaderView: UITableViewHeaderFooterView {
    
    // Reuse Identifier
    static let reuseIdentifier = "UNPINNED_HEADER"
    
    // Subviews
    let titleLabel = UILabel()
    let bottomSeparator = UIView()
    
    
    // MARK: - Initialization
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureSubviews()
        configureLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureSubviews() {
        // Add Subviews
        contentView.addSubview(titleLabel)
        contentView.addSubview(bottomSeparator)
        
        // Style View
        contentView.backgroundColor = .lfMediumGray()
        
        // Style Subviews
        titleLabel.text = "UNPINNED PLAYLISTS"
        titleLabel.textColor = .lfPinnedHeaderTextGray()
        titleLabel.font = UIFont.systemFontOfSize(12, weight: UIFontWeightMedium)
        
        bottomSeparator.backgroundColor = .lfSeparatorUnpinnedGray()
    }
    
    func configureLayout() {
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(titleLabel, bottomSeparator)
        
        // Add Constraints
        NSLayoutConstraint.activateConstraints([
            titleLabel.leftAnchor.constraintEqualToAnchor(contentView.leftAnchor, constant: 10),
            titleLabel.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor, constant: -9),
            
            bottomSeparator.leftAnchor.constraintEqualToAnchor(contentView.leftAnchor),
            bottomSeparator.rightAnchor.constraintEqualToAnchor(contentView.rightAnchor),
            bottomSeparator.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor),
            bottomSeparator.heightAnchor.constraintEqualToConstant(0.8)
            ])
    }
    
}
