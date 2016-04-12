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
    let showPinnedPlaylistsButton = UIButton()
    
    
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
        
        // Style View
        contentView.backgroundColor = .lfDarkGray()
        backgroundColor = contentView.backgroundColor
        selectionStyle = .None
        alpha = 0 // Initially hidden
        
        // Style Subviews
        showPinnedPlaylistsButton.setTitle("Show Pinned Playlists", forState: .Normal)
        showPinnedPlaylistsButton.setTitleColor(.whiteColor(), forState: .Normal)
        showPinnedPlaylistsButton.setTitleColor(.lfGreen(), forState: .Highlighted)
        showPinnedPlaylistsButton.titleLabel!.font = UIFont.systemFontOfSize(12, weight: UIFontWeightMedium)
        showPinnedPlaylistsButton.setImage(UIImage(named: "DownArrow_White"), forState: .Normal)
        showPinnedPlaylistsButton.setImage(UIImage(named: "DownArrow_Green"), forState: .Highlighted)
    }
    
    func configureLayout() {
        setTranslatesAutoresizingMaskIntoConstraintsToFalse([showPinnedPlaylistsButton])
        
        // Add Constraints
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
    
}

