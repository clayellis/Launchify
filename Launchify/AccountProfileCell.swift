//
//  AccountProfileCell.swift
//  Launchify
//
//  Created by Clay Ellis on 4/24/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//


import UIKit

class AccountProfileCell: UITableViewCell {
    
    // Reuse Identifier
    static let reuseIdentifier = "ACCOUNT_PROFILE"
    
    // Subviews
    let profileImageView = UIImageView()
    let usernameLabel = UILabel()
    let accountTypeLogoutContainer = UIStackView()
    let accountTypeLabel = UILabel()
    let logoutButton = UIButton()
    let purchaseButton = UIButton()
    let restoreButton = UIButton()
    
    
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
        contentView.addSubview(profileImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(accountTypeLogoutContainer)
        accountTypeLogoutContainer.addArrangedSubview(accountTypeLabel)
        accountTypeLogoutContainer.addArrangedSubview(logoutButton)
        contentView.addSubview(purchaseButton)
        contentView.addSubview(restoreButton)
        
        // Style View
        preservesSuperviewLayoutMargins = false
        layoutMargins = UIEdgeInsetsZero
        separatorInset = UIEdgeInsetsZero
        contentView.backgroundColor = .lfDarkGray()
        backgroundColor = contentView.backgroundColor
        selectionStyle = .None
        
        // Style Subviews
        profileImageView.image = UIImage(named: "Kelsey")
        profileImageView.backgroundColor = .lfGreen()
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.borderColor = UIColor.whiteColor().colorWithAlphaComponent(0.4).CGColor
        profileImageView.contentMode = .ScaleAspectFill
        profileImageView.clipsToBounds = true
        
        usernameLabel.text = "Kelsey Pappa"
        usernameLabel.textColor = .whiteColor()
        usernameLabel.textAlignment = .Center
        usernameLabel.font = .systemFontOfSize(17, weight: UIFontWeightMedium)
        
        accountTypeLogoutContainer.axis = .Horizontal
        accountTypeLogoutContainer.spacing = 7
        
        accountTypeLabel.text = "Spotify Premium  •"
        accountTypeLabel.textColor = .lfAccountTypeTextGray()
        accountTypeLabel.font = .systemFontOfSize(13, weight: UIFontWeightMedium)
        
        logoutButton.setTitle("Logout", forState: .Normal)
        logoutButton.setTitleColor(UIColor.lfAccountTypeTextGray(), forState: .Normal)
        logoutButton.setTitleColor(UIColor.lfAccountTypeTextGray().colorWithAlphaComponent(0.5), forState: .Highlighted)
        logoutButton.titleLabel!.font = accountTypeLabel.font
//        logoutButton.contentEdgeInsets = UIEdgeInsets(top: 15, left: 7, bottom: 15, right: 0) // TODO: Make the logout button more tappable
        
        purchaseButton.setTitle("Remove Pin Limit", forState: .Normal)
        purchaseButton.setTitleColor(.whiteColor(), forState: .Normal)
        purchaseButton.setBackgroundImage(UIImage(named: "GreenButton_Background"), forState: .Normal)
        purchaseButton.titleLabel!.font = .systemFontOfSize(13)
        purchaseButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        
        restoreButton.setTitle("Restore Purchase", forState: .Normal)
        restoreButton.setTitleColor(UIColor.lfRestoreTextGray(), forState: .Normal)
        restoreButton.setTitleColor(UIColor.lfRestoreTextGray().colorWithAlphaComponent(0.5), forState: .Highlighted)
        restoreButton.titleLabel!.font = .systemFontOfSize(11)
    }
    
    func configureLayout() {
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(
            [profileImageView, usernameLabel, accountTypeLogoutContainer, accountTypeLabel, logoutButton, purchaseButton, restoreButton])
        
        // Add Constraints
        NSLayoutConstraint.activateConstraints([
            profileImageView.centerXAnchor.constraintEqualToAnchor(contentView.centerXAnchor),
            profileImageView.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 20),
            profileImageView.widthAnchor.constraintEqualToConstant(90),
            profileImageView.heightAnchor.constraintEqualToAnchor(profileImageView.widthAnchor),
            
            usernameLabel.centerXAnchor.constraintEqualToAnchor(contentView.centerXAnchor),
            usernameLabel.topAnchor.constraintEqualToAnchor(profileImageView.bottomAnchor, constant: 25),
            
            accountTypeLogoutContainer.centerXAnchor.constraintEqualToAnchor(contentView.centerXAnchor),
            accountTypeLogoutContainer.topAnchor.constraintEqualToAnchor(usernameLabel.bottomAnchor),
            
            purchaseButton.centerXAnchor.constraintEqualToAnchor(contentView.centerXAnchor),
            purchaseButton.topAnchor.constraintEqualToAnchor(accountTypeLogoutContainer.bottomAnchor, constant: 20),
            
            restoreButton.centerXAnchor.constraintEqualToAnchor(contentView.centerXAnchor),
            restoreButton.topAnchor.constraintEqualToAnchor(purchaseButton.bottomAnchor, constant: 5),
            restoreButton.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor, constant: -5)
            ])
    }
    // -----------------------------------------------------------------------------------------------------------------------------------------^
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Make the profileImageView a circle
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
    }

}
