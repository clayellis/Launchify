//
//  PagingViewController.swift
//  Launchify
//
//  Created by Clay Ellis on 4/4/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//

import UIKit


class PagingViewController: UIViewController {
    
    // View
    let pagingView = PagingView()
    // --------------------------------
    let pinnedPlaylistsViewController = PinnedPlaylistsViewController()
    let needHelpViewController = NeedHelpViewController()
    
    // Model
    
    
    // Properties
    
    
    
    // MARK: View Controller Life Cycle
    override func loadView() {
        self.view = pagingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurePagingController()
    }
    
    // MARK: - Configuration Methods
    func configurePagingController() {
        // Set this view controller's title
        title = "Launchify"

        // Set the parentViewController on the paging controller
        LFPagingController.sharedInstance.parentViewController = self
        
        // Set the titles on the view controllers to add as paging view controllers
        pinnedPlaylistsViewController.title = "Pinned Playlists"
        needHelpViewController.title = "Need Help?"
        
        // Add the paging view controllers to the paging controller
        LFPagingController.sharedInstance.addPagingViewController(pinnedPlaylistsViewController)
        LFPagingController.sharedInstance.addPagingViewController(needHelpViewController)
    }
    
}
