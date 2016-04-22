//
//  PagingViewController.swift
//  Launchify
//
//  Created by Clay Ellis on 4/4/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//

import UIKit


class PagingContainerViewController: UIViewController, LFPagingControllerPagingDelegate {
    
    // View
    let pagingView = PagingView()
    
    // Paging Views
    let pinnedPlaylistsViewController = PinnedPlaylistsViewController()
    let needHelpViewController = NeedHelpViewController()
    
    // Model
    
    
    // Properties
    
    
    
    // MARK: Life Cycle
    // -----------------------------------------------------------------------------------------------------------------------------------------v
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
        pagingView.pagingController.parentViewController = self
        
        // Set the titles on the view controllers to add as paging view controllers
        pinnedPlaylistsViewController.title = "Pinned Playlists"
        needHelpViewController.title = "Need Help?"
        
        // Add the paging view controllers to the paging controller
        pagingView.pagingController.addPagingViewController(pinnedPlaylistsViewController)
        pagingView.pagingController.addPagingViewController(needHelpViewController)
    }
    // -----------------------------------------------------------------------------------------------------------------------------------------^
    
    // MARK: Animations
    // -----------------------------------------------------------------------------------------------------------------------------------------v
    override func viewWillAppear(animated: Bool) {
        // Animate in the views beyond the top level (title, page titles, subview trees of each paging view)
        animateSubviewsInView(pagingView.pagingController.topBar)
        animateSubviewsInView(pinnedPlaylistsViewController.view)
        animateSubviewsInView(needHelpViewController.view)
    }
    
    func animateSubviewsInView(view: UIView) {
        for subview in view.subviews {
            subview.alpha = 0
            subview.transform = CGAffineTransformMakeScale(0.96, 0.96)
            UIView.animateWithDuration(0.4, delay: 0, options: [.CurveEaseOut], animations: {
                subview.alpha = 1
                subview.transform = CGAffineTransformIdentity
                }, completion: nil)
        }
    }
    // -----------------------------------------------------------------------------------------------------------------------------------------^
    
}
