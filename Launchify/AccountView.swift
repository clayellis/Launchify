//
//  AccountView.swift
//  Launchify
//
//  Created by Clay Ellis on 4/8/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//

import UIKit

class AccountView: UIView {
    
    // Subviews
    let tableView = UITableView(frame: .zero, style: .Grouped)
    let appsidianImageView = UIImageView()
    
    // MARK: - Initialization
    convenience init() {
        self.init(frame: .zero)
        configureSubviews()
        configureLayout()
    }
    
    func configureSubviews() {
        // Add Subviews
        addSubview(tableView)
        
        // Style View
        backgroundColor = .lfMediumGray()
        
        // Style Subviews
        tableView.estimatedRowHeight = 55
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorColor = .lfDarkestGray() // TODO: < Find the right color for this
        tableView.backgroundColor = .lfMediumGray()
        tableView.contentInset = UIEdgeInsets(top: LFPagingController.topBarBarHeight, left: 0, bottom: 0, right: 0)
        tableView.fixDelaysContentTouches()
        
        appsidianImageView.image = UIImage(named: "Appsidian")
        appsidianImageView.contentMode = .Center
//        tableView.tableFooterView = appsidianImageView
    }
    
    func configureLayout() {
        setTranslatesAutoresizingMaskIntoConstraintsToFalse([tableView])
        
        // Add Constraints
        tableView.fillSuperview()
    }
    
}
