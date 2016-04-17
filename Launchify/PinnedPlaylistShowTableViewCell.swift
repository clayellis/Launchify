//
//  PinnedPlaylistShowTableViewCell.swift
//  Launchify
//
//  Created by Clay Ellis on 4/9/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//

import UIKit

class PinnedPlaylistShowTableViewCell: UITableViewCell {
    
    // Reuse Identifier
    static let reuseIdentifier = "SHOW_ALL"
    
    // Subviews
    let topSeparator = UIView()
    let showPinnedPlaylistsButton = UIButton()
    
    // State
    var inShowState = false {
        didSet {
            showPinnedPlaylistsButton.selected = !inShowState
            setNeedsLayout()
        }
    }
    
    // MARK: - Initialization
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSubviews()
        configureLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration Methods
    func configureSubviews() {
        // Add Subviews
        contentView.addSubview(showPinnedPlaylistsButton)
        addSubview(topSeparator)
        
        // Style View
        contentView.backgroundColor = .lfDarkGray()
        backgroundColor = contentView.backgroundColor
        selectionStyle = .None
        alpha = 0 // Initially hidden        
        preservesSuperviewLayoutMargins = false
        layoutMargins = UIEdgeInsetsZero
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        // Style Subviews
        topSeparator.backgroundColor = .lfSeparatorGray()
        
        // This is a UIKit mess... really wish Apple would improve this
        let hideTitle = "Hide Pinned Playlists"
        let showTitle = "Show Pinned Playlists"
        showPinnedPlaylistsButton.setTitle(hideTitle, forState: .Normal)
        showPinnedPlaylistsButton.setTitle(hideTitle, forState: [.Normal, .Highlighted])
        showPinnedPlaylistsButton.setTitle(showTitle, forState: .Selected)
        showPinnedPlaylistsButton.setTitle(showTitle, forState: [.Selected, .Highlighted])
        
        showPinnedPlaylistsButton.setTitleColor(.whiteColor(), forState: .Normal)
        showPinnedPlaylistsButton.setTitleColor(.lfGreen(), forState: [.Normal, .Highlighted])
        showPinnedPlaylistsButton.setTitleColor(.whiteColor(), forState: .Selected)
        showPinnedPlaylistsButton.setTitleColor(.lfGreen(), forState: [.Selected, .Highlighted])
        
        let downWhite = "DownArrow_White"
        let downGreen = "DownArrow_Green"
        let upWhite = "UpArrow_White"
        let upGreen = "UpArrow_Green"
        showPinnedPlaylistsButton.setImage(UIImage(named: upWhite), forState: .Normal)
        showPinnedPlaylistsButton.setImage(UIImage(named: upGreen), forState: [.Normal, .Highlighted])
        showPinnedPlaylistsButton.setImage(UIImage(named: downWhite), forState: .Selected)
        showPinnedPlaylistsButton.setImage(UIImage(named: downGreen), forState: [.Selected, .Highlighted])
        
        showPinnedPlaylistsButton.titleLabel!.font = UIFont.systemFontOfSize(12, weight: UIFontWeightMedium)
        
        showPinnedPlaylistsButton.addTarget(self, action: #selector(showTapped), forControlEvents: .TouchUpInside)
    }
    
    func configureLayout() {
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(topSeparator, showPinnedPlaylistsButton)
        
        // Add Constraints
        NSLayoutConstraint.activateConstraints([
            topSeparator.leftAnchor.constraintEqualToAnchor(leftAnchor),
            topSeparator.rightAnchor.constraintEqualToAnchor(rightAnchor),
            topSeparator.topAnchor.constraintEqualToAnchor(topAnchor, constant: -0.2),
            topSeparator.heightAnchor.constraintEqualToConstant(0.7)
            ])
        
        showPinnedPlaylistsButton.fillSuperview()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Shift the arrow image to the right side of the title
        let titleWidth = showPinnedPlaylistsButton.titleLabel!.intrinsicContentSize().width
        let arrowImageWidth = showPinnedPlaylistsButton.imageView!.frame.width
        let padding: CGFloat = 0
        let imageInset = titleWidth + arrowImageWidth + padding
        showPinnedPlaylistsButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: imageInset, bottom: 0, right: -imageInset)
        showPinnedPlaylistsButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -arrowImageWidth, bottom: 0, right: arrowImageWidth)
    }
    
    func showTapped() {
        // Toggling inShowState adjusts button states
        inShowState = !inShowState
    }
}

