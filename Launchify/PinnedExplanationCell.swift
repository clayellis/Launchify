//
//  PinnedExplanationCell.swift
//  Launchify
//
//  Created by Clay Ellis on 4/18/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//

import UIKit

class PinnedExplanationCell: UITableViewCell {
   
    // Reuse Identifier
    static let reuseIdentifier = "PINNED_EXPLANATION"
    
    // Subviews
    let explanationLabel = UILabel()
    
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
        contentView.addSubview(explanationLabel)
        
        // Style View
        preservesSuperviewLayoutMargins = false
        layoutMargins = UIEdgeInsetsZero
        separatorInset = UIEdgeInsetsZero
        contentView.backgroundColor = .lfDarkGray()
        backgroundColor = contentView.backgroundColor
        selectionStyle = .None
        
        // Style Subviews
        explanationLabel.text = "Quickly launch your pinned playlists from the Launchify widget in Notification Center."
        explanationLabel.textColor = .lfPinnedExplanationTextGray()
        explanationLabel.font = UIFont.systemFontOfSize(15)
        explanationLabel.textAlignment = .Center
        explanationLabel.numberOfLines = 2
        explanationLabel.lineBreakMode = .ByWordWrapping
        explanationLabel.adjustsFontSizeToFitWidth = true
    }
    
    func configureLayout() {
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(explanationLabel)
        
        // Add Constraints
        explanationLabel.fillSuperview()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Dim the separator
        if let separator = subviewWithClassName("_UITableViewCellSeparatorView") {
            separator.alpha = 0.46
        }
    }
    // -----------------------------------------------------------------------------------------------------------------------------------------^
}
