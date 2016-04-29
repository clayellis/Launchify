//
//  PlaylistTableViewCell.swift
//  Launchify
//
//  Created by Clay Ellis on 4/8/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//

import UIKit

class PlaylistTableViewCell: UITableViewCell {
    
    // Reuse Identifier
    static let unpinnedReuseIdentifier = "UNPINNED"
    static let pinnedReuseIdentifier = "PINNED"
    
    // Subviews
    let toggleButton = UIButton()
    let titleLabel = UILabel()
    
    // Stored Constraints
    var titleLabelRight: NSLayoutConstraint!
    
    // State
    var fake = false // When set to true, the contentView, separatorView, and reorderControl are all dimmed with low alphas
    let fakeAlpha: CGFloat = 0.06
    
    // MARK: - Initialization
    // -----------------------------------------------------------------------------------------------------------------------------------------v
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSubviews()
        configureLayout()
    }
    // -----------------------------------------------------------------------------------------------------------------------------------------^
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration Methods
    // -----------------------------------------------------------------------------------------------------------------------------------------v
    private func configureSubviews() {
        // Add Subviews
        contentView.addSubview(toggleButton)
        contentView.addSubview(titleLabel)
        
        // Style View
        preservesSuperviewLayoutMargins = false
        layoutMargins = UIEdgeInsetsZero
        
        // Style Subviews
        if reuseIdentifier == PlaylistTableViewCell.pinnedReuseIdentifier {            
            // Cell color
            contentView.backgroundColor = .lfDarkGray()
            
            // Toggle Button image for state
            toggleButton.setImage(UIImage(named: "Toggle_Pinned_Normal"), forState: .Normal)
            toggleButton.setImage(UIImage(named: "Toggle_Pinned_Highlighted"), forState: .Highlighted)
            toggleButton.setImage(UIImage(named: "Toggle_Unpinned_Normal"), forState: .Selected)
            
            titleLabel.textColor = .whiteColor()
            titleLabel.font = UIFont.systemFontOfSize(18)
            
            let viewForSelectedBackgroundView = UIView()
            viewForSelectedBackgroundView.backgroundColor = .lfDarkestGray()
            selectedBackgroundView = viewForSelectedBackgroundView
        
        } else if reuseIdentifier == PlaylistTableViewCell.unpinnedReuseIdentifier {
            // Cell color
            contentView.backgroundColor = .lfMediumGray()
            
            toggleButton.setImage(UIImage(named: "Toggle_Unpinned_Normal"), forState: .Normal)
            toggleButton.setImage(UIImage(named: "Toggle_Unpinned_Highlighted"), forState: .Highlighted)
            toggleButton.setImage(UIImage(named: "Toggle_Pinned_Normal"), forState: .Selected)
            
            titleLabel.textColor = .lfLightGray()
            titleLabel.font = UIFont.systemFontOfSize(17)
            
            let viewForSelectedBackgroundView = UIView()
            viewForSelectedBackgroundView.backgroundColor = .lfGreen()
            selectedBackgroundView = viewForSelectedBackgroundView
        }
        
        backgroundColor = contentView.backgroundColor
        toggleButton.addTarget(self, action: #selector(toggleButtonTouchUpInside(_:)), forControlEvents: .TouchUpInside)
    }

    private func configureLayout() {
        setTranslatesAutoresizingMaskIntoConstraintsToFalse([toggleButton, titleLabel])
        
        // Add Constraints
        titleLabelRight = titleLabel.rightAnchor.constraintEqualToAnchor(contentView.rightAnchor, constant: -15)
        
        NSLayoutConstraint.activateConstraints([
            toggleButton.leftAnchor.constraintEqualToAnchor(contentView.leftAnchor),
            toggleButton.widthAnchor.constraintEqualToConstant(54),
            toggleButton.topAnchor.constraintEqualToAnchor(contentView.topAnchor),
            toggleButton.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor),
            
            titleLabel.leftAnchor.constraintEqualToAnchor(toggleButton.rightAnchor),
            titleLabelRight,
            titleLabel.centerYAnchor.constraintEqualToAnchor(contentView.centerYAnchor),
            ])
    }
    
    internal func configureCellWithPlaylist(playlist: LaunchifyPlaylist) {
        toggleButton.selected = false
        titleLabel.text = playlist.playlistTitle
    }
    
    func makeFake(fake: Bool) {
        self.fake = fake
        contentView.alpha = fake ? fakeAlpha : 1
        userInteractionEnabled = !fake
        if let separator = subviewWithClassName("_UITableViewCellSeparatorView") {
            separator.alpha = fake ? fakeAlpha + 0.4 : 1
        }
    }
    // -----------------------------------------------------------------------------------------------------------------------------------------^
    
    
    // MARK: Toggle Button
    // -----------------------------------------------------------------------------------------------------------------------------------------v
    @objc private func toggleButtonTouchUpInside(sender: UIButton) {
        sender.selected = true
    }
    // -----------------------------------------------------------------------------------------------------------------------------------------^
    
    
    // MARK: Reorder Control
    // -----------------------------------------------------------------------------------------------------------------------------------------v
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            if let reorderControl = subviewWithClassName("UITableViewCellReorderControl"),
                reorderControlImageView = reorderControl.subviewWithClassType(UIImageView.self) as? UIImageView {
                reorderControlImageView.image = UIImage(named: "ReorderControl")!
                reorderControlImageView.contentMode = .Center
                reorderControlImageView.alpha = fake ? fakeAlpha + 0.2 : 1
                
                titleLabelRight.active = false
                titleLabel.rightAnchor.constraintEqualToAnchor(reorderControl.leftAnchor, constant: -15)
                titleLabelRight.active = true
            }
        }
    }
    // -----------------------------------------------------------------------------------------------------------------------------------------^
    

    // MARK: Animation Methods
    // -----------------------------------------------------------------------------------------------------------------------------------------v
    func didHighlight() {
        if reuseIdentifier == PlaylistTableViewCell.pinnedReuseIdentifier {
            titleLabel.font = UIFont.systemFontOfSize(17)
            titleLabel.textColor = .lfLightGray()
            toggleButton.setImage(UIImage(named: "Toggle_Unpinned_Normal"), forState: toggleButton.state)
        } else if reuseIdentifier == PlaylistTableViewCell.unpinnedReuseIdentifier {
            titleLabel.font = UIFont.systemFontOfSize(17, weight: UIFontWeightSemibold)
            titleLabel.textColor = .whiteColor()
            toggleButton.setImage(UIImage(named: "Toggle_Unpinned_White"), forState: toggleButton.state)
        }
    }
    
    func didUnhighlight() {
        let duration: NSTimeInterval = 0.2
        var normalImage: UIImage?
        var normalFont: UIFont?
        var normalTextColor: UIColor?
        
        if reuseIdentifier == PlaylistTableViewCell.pinnedReuseIdentifier {
            normalImage = UIImage(named: "Toggle_Pinned_Normal")
            normalFont = UIFont.systemFontOfSize(18)
            normalTextColor = .whiteColor()
        } else if reuseIdentifier == PlaylistTableViewCell.unpinnedReuseIdentifier {
            normalImage = UIImage(named: "Toggle_Unpinned_Normal")
            normalFont = UIFont.systemFontOfSize(17)
            normalTextColor = .lfLightGray()
        }
        
        // Change the font weight and color back to normal
        UIView.transitionWithView(titleLabel, duration: duration, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            self.titleLabel.font = normalFont
            self.titleLabel.textColor = normalTextColor
            }, completion: nil)
        
        // Dissolve between the current toggle image and the normal toggle image
        let crossDissolve = CABasicAnimation(keyPath: "contents")
        crossDissolve.duration = duration
        crossDissolve.fromValue = toggleButton.currentImage!.CGImage
        crossDissolve.toValue = normalImage?.CGImage
        crossDissolve.removedOnCompletion = false
        crossDissolve.fillMode = kCAFillModeBackwards
        toggleButton.imageView!.layer.addAnimation(crossDissolve, forKey: "animateContents")
        toggleButton.setImage(normalImage, forState: .Normal)
    }
    // -----------------------------------------------------------------------------------------------------------------------------------------^
    
}



