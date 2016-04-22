//
//  PinnedPlaylistsView.swift
//  Launchify
//
//  Created by Clay Ellis on 4/8/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//

import UIKit

/// Discards touches that are below the lowest content
class PinnedTableView: UITableView {
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        return point.y < contentSize.height + 10 // + 10 as an assistance buffer
    }
}

class PinnedPlaylistsView: UIView {
    
    // Paging Controller
    var pagingController: LFPagingController?
    
    // Subviews
    //  Subviews - Pinned
    let pinnedTableView = PinnedTableView()
    let pinnedBackroundView = UIView()
    let pinnedSeparator = UIView()
    let fauxPinnedHandle = UIImageView() // Sits behind the actual pinned handle (which disappears while rows are inserted/deleted from pinned)
    var pinnedFooterView: PinnedPlaylistFooterView? // Maintain a reference in order to adjust the highlighted image after showing/hiding
    let pinnedExplanationView = PinnedExplanationView()
    
    //  Subviews - Unpinned
    let unpinnedRefreshControl = UIRefreshControl()
    var unpinnedSearchBar: UISearchBar! // Initialize later in configureSubviews
    let unpinnedTableView = UITableView(frame: .zero, style: .Grouped)
    
    // Appearance Values
    var pinnedSeparatorHeight: CGFloat = 0.7
    
    // Stored Constraints
    var pinnedBackgroundViewHeight: NSLayoutConstraint!
    var unpinnedTableViewTop: NSLayoutConstraint!
    
    // Pinned Table Show/Hide Values
    var pinnedPlaylistsHidden = false
    var autoShowingPinnedPlaylists = false
    var autoHidingPinnedPlaylists = false
    
    
    // Convenience Values
    var pinnedTableViewHeightMinusFooter: CGFloat {
        return pinnedTableView.contentSize.height - pinnedTableView.sectionFooterHeight
    }
    
    var currentTopBarHeight: CGFloat {
        let normalTopBarHeight = LFPagingController.topBarBarHeight
        let topBarOffset = pagingController!.topBar.transform.ty
        return normalTopBarHeight + topBarOffset // (+ because transform is always negative)
    }
    
    // MARK: - Initialization
    convenience init() {
        self.init(frame: .zero)
        configureSubviews()
        configureLayout()
    }
    
    func configureSubviews() {
        // Add Subviews
        addSubview(unpinnedTableView)
        unpinnedTableView.addSubview(unpinnedRefreshControl)
        addSubview(pinnedBackroundView)
        pinnedBackroundView.addSubview(fauxPinnedHandle)
        pinnedBackroundView.addSubview(pinnedSeparator)
        addSubview(pinnedTableView)
        pinnedTableView.addSubview(pinnedExplanationView)
        
        // Style View
        clipsToBounds = true
        
        // Style Subviews
        unpinnedTableView.sectionHeaderHeight = 0
        pinnedTableView.rowHeight = 60
        pinnedTableView.sectionFooterHeight = 25
        pinnedBackroundView.backgroundColor = .lfDarkGray()
        pinnedBackroundView.layer.shadowColor = UIColor.blackColor().CGColor
        pinnedBackroundView.layer.shadowOpacity = 0.7
        pinnedBackroundView.layer.shadowRadius = 15
        pinnedBackroundView.layer.shadowOffset = CGSize(width: 0, height: 7)
        
        fauxPinnedHandle.image = UIImage(named: "PinnedHandle_Normal")
        fauxPinnedHandle.contentMode = .Center
        
        pinnedSeparator.backgroundColor = .lfSeparatorPinnedGray()
        
        // (Insets and offsets are set in configureInitialAppearance)
        pinnedTableView.editing = true
        pinnedTableView.allowsSelectionDuringEditing = true
        pinnedTableView.showsVerticalScrollIndicator = false
        pinnedTableView.backgroundColor = .clearColor()
        pinnedTableView.separatorColor = .lfSeparatorGray()
        pinnedTableView.separatorInset = UIEdgeInsets(top: 0, left: 54, bottom: 0, right: 0)
        pinnedTableView.tableFooterView = UIView()
        pinnedTableView.delaysContentTouches = false
        
        
        let searchBarHeight: CGFloat = 60
        unpinnedSearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 0, height: searchBarHeight))
//        unpinnedSearchBar.searchFieldBackgroundPositionAdjustment = UIOffset(horizontal: 0, vertical: searchBarHeight / 4)
        unpinnedSearchBar.searchBarStyle = .Minimal
        unpinnedSearchBar.tintColor = .lfGreen()
        unpinnedSearchBar.placeholder = "Search"
        unpinnedSearchBar.keyboardAppearance = .Dark
        let searchBarTextField = unpinnedSearchBar.valueForKey("searchField") as? UITextField
        searchBarTextField?.textColor = .whiteColor()
        unpinnedTableView.tableHeaderView = unpinnedSearchBar

        // (Insets and offsets are set in configureInitialAppearance)
        unpinnedTableView.sectionHeaderHeight = 55
        unpinnedTableView.rowHeight = 60
        unpinnedTableView.sectionFooterHeight = 0
        unpinnedTableView.backgroundColor = .lfMediumGray()
        unpinnedTableView.separatorColor = .lfSeparatorGray()
        unpinnedTableView.separatorInset = UIEdgeInsets(top: 0, left: 54, bottom: 0, right: 0)
        unpinnedTableView.delaysContentTouches = false
        unpinnedTableView.sendSubviewToBack(unpinnedRefreshControl)
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Optimize the shadow rendering by providing a shadow path (causes shadow to jump, cannot animate)
//        pinnedBackroundView.layer.shadowPath = UIBezierPath(rect: pinnedBackroundView.bounds).CGPath
    }
    
    // Called from viewWillAppear()
    func configureInitialAppearance() {
        pinnedTableView.contentInset = UIEdgeInsets(top: currentTopBarHeight, left: 0, bottom: 0, right: 0)
        pinnedTableView.contentOffset.y = -pinnedTableView.contentInset.top
        
        // Force the pinned table view to load its data since adjustUpinnedPlaylistsContent relies on its content size
        pinnedTableView.reloadData()
//        adjustUnpinnedPlaylistsContent(andScrollToTop: true)
        updatePinnedTableBackgroundHeight(withOffset: 0)
        updateUnpinnedTableViewTop()
        
        // Hide the empty UI
        hideEmptyUI()
    }
    
    func configureLayout() {
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(pinnedBackroundView, fauxPinnedHandle, pinnedSeparator, pinnedTableView, pinnedExplanationView, unpinnedTableView)
        
        // Add Constraints
        pinnedBackgroundViewHeight = pinnedBackroundView.heightAnchor.constraintEqualToConstant(LFPagingController.topBarBarHeight)
        unpinnedTableViewTop = unpinnedTableView.topAnchor.constraintEqualToAnchor(topAnchor)
        
        NSLayoutConstraint.activateConstraints([
            pinnedBackroundView.leftAnchor.constraintEqualToAnchor(leftAnchor),
            pinnedBackroundView.rightAnchor.constraintEqualToAnchor(rightAnchor),
            pinnedBackroundView.topAnchor.constraintEqualToAnchor(topAnchor),
            pinnedBackgroundViewHeight,
            
            fauxPinnedHandle.leftAnchor.constraintEqualToAnchor(pinnedBackroundView.leftAnchor),
            fauxPinnedHandle.rightAnchor.constraintEqualToAnchor(pinnedBackroundView.rightAnchor),
            fauxPinnedHandle.bottomAnchor.constraintEqualToAnchor(pinnedSeparator.topAnchor),
            fauxPinnedHandle.heightAnchor.constraintEqualToConstant(pinnedTableView.sectionFooterHeight),
            
            pinnedSeparator.leftAnchor.constraintEqualToAnchor(pinnedBackroundView.leftAnchor),
            pinnedSeparator.rightAnchor.constraintEqualToAnchor(pinnedBackroundView.rightAnchor),
            pinnedSeparator.bottomAnchor.constraintEqualToAnchor(pinnedBackroundView.bottomAnchor),
            pinnedSeparator.heightAnchor.constraintEqualToConstant(pinnedSeparatorHeight),
            
            pinnedExplanationView.topAnchor.constraintEqualToAnchor(pinnedTableView.topAnchor, constant: pinnedTableView.rowHeight),
            pinnedExplanationView.leftAnchor.constraintEqualToAnchor(pinnedTableView.leftAnchor),
            pinnedExplanationView.widthAnchor.constraintEqualToAnchor(pinnedTableView.widthAnchor),
            pinnedExplanationView.heightAnchor.constraintEqualToConstant(pinnedTableView.rowHeight * 2),
            
            unpinnedTableView.leftAnchor.constraintEqualToAnchor(leftAnchor),
            unpinnedTableView.rightAnchor.constraintEqualToAnchor(rightAnchor),
            unpinnedTableView.bottomAnchor.constraintEqualToAnchor(bottomAnchor),
            unpinnedTableViewTop
            ])
    
        pinnedTableView.fillSuperview()
//        unpinnedTableView.fillSuperview()
    }
    

    func updatePinnedTableBackgroundHeight(withOffset offset: CGFloat) {
        pinnedBackgroundViewHeight.active = false
        pinnedBackgroundViewHeight.constant =
            currentTopBarHeight + pinnedTableView.contentSize.height + pinnedTableView.transform.ty + pinnedSeparatorHeight + offset
            - (pinnedTableView.contentOffset.y + pinnedTableView.contentInset.top)
        pinnedBackgroundViewHeight.active = true
    }
    
    func updatePinnedTableBackgroundHeight() {
        updatePinnedTableBackgroundHeight(withOffset: 0)
    }
    
    func updateUnpinnedTableViewTop() {
        unpinnedTableViewTop.active = false
        
        // If the pinned transform is 0, use the background height
        
        
        unpinnedTableViewTop.constant = currentTopBarHeight + pinnedTableView.contentSize.height + pinnedTableView.transform.ty + pinnedSeparatorHeight
        unpinnedTableViewTop.active = true
    }
    
    func showEmptyUI() {
        UIView.animateWithDuration(0.7, animations: {
            self.pinnedExplanationView.alpha = 1
        })
    }
    
    func hideEmptyUI() {
//        UIView.animateWithDuration(0.4, animations: {
            self.pinnedExplanationView.alpha = 0
//        })
    }
}

// MARK: - Pinned Playlist Table Scrolling / Showing / Hiding Animation Methods
extension PinnedPlaylistsView: LFPagingControllerPagingDelegate {
    
    // MARK: LFPagingControllerPagingDelegate
    func pagingControll(affectingScrollViewDidScrollPastThreshold threshold: CGFloat, withOffset offset: CGFloat, draggingUp: Bool) {
        let hideThreshold: CGFloat = threshold + 45
        let showThreshold: CGFloat = threshold + 100
        if draggingUp && offset > hideThreshold && !pinnedPlaylistsHidden {
            hidePinnedPlaylists(withSpring: true, andScrollUnpinnedToTop: false)
        } else if !draggingUp && offset > showThreshold && pinnedPlaylistsHidden {
            showPinnedPlaylists(withSpring: true, andScrollUnpinnedToTop: false)
        }
    }
    
    
    // MARK: Scrolling
    func pagingControllerTopBarTYDidChange(newTy ty: CGFloat) {
        // Currently not using newTy (we could, but it's more readable to use self.currentTopBarHeight instead)
        pinnedTableView.contentInset.top = currentTopBarHeight
        updatePinnedTableBackgroundHeight(withOffset: 0)
    }
    
    func pinnedPlaylistTableViewDidScroll() {
        let offsetY = pinnedTableView.contentOffset.y + pinnedTableView.contentInset.top
        if !autoShowingPinnedPlaylists && !autoHidingPinnedPlaylists {
            let threshold: CGFloat = 65
            if pinnedPlaylistsHidden {
                if offsetY < -threshold {
                    showPinnedPlaylists(withSpring: true, andScrollUnpinnedToTop: true)
                }
            } else {
                if offsetY > threshold {
                    hidePinnedPlaylists(withSpring: true, andScrollUnpinnedToTop: true)
                }
            }
        }
        updatePinnedTableBackgroundHeight()
    }
    
    
    // MARK: Showing / Hiding
    func showPinnedPlaylistsTapped(sender: UIButton) {
        if pinnedPlaylistsHidden {
            showPinnedPlaylists(withSpring: true, andScrollUnpinnedToTop: true)
        } else {
            hidePinnedPlaylists(withSpring: true, andScrollUnpinnedToTop: true)
        }
    }
    
    // TODO: Document these methods
    func showPinnedPlaylists(withSpring spring: Bool, andScrollUnpinnedToTop scrollUnpinnedToTop: Bool) {
        if autoShowingPinnedPlaylists || !pinnedPlaylistsHidden { return }
        
        autoShowingPinnedPlaylists = true
        autoHidingPinnedPlaylists = false
        
        let animations: () -> Void = {
            self.pinnedTableView.transform.ty = 0
            self.updatePinnedTableBackgroundHeight()
            self.updateUnpinnedTableViewTop()
            self.layoutIfNeeded()
        }
        
        let completion: (Bool) -> Void = { _ in
            self.autoShowingPinnedPlaylists = false
            self.autoHidingPinnedPlaylists = false
            self.pinnedPlaylistsHidden = false
        }
        
        if spring {
            let options: UIViewAnimationOptions = [.BeginFromCurrentState, .LayoutSubviews, .AllowUserInteraction]
            UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: options, animations: animations, completion: completion)
        } else {
            UIView.animateWithDuration(0.4, animations: animations, completion: completion)
        }
        
        pinnedFooterView!.adjustImageToState(.Normal)
//        adjustUnpinnedPlaylistsContent(andScrollToTop: scrollUnpinnedToTop)
    }
    
    func hidePinnedPlaylists(withSpring spring: Bool, andScrollUnpinnedToTop scrollUnpinnedToTop: Bool) {
        if autoHidingPinnedPlaylists || pinnedPlaylistsHidden { return }

        autoHidingPinnedPlaylists = true
        autoShowingPinnedPlaylists = false
        
        let animations: () -> Void = {
            self.pinnedTableView.transform.ty = -self.pinnedTableViewHeightMinusFooter - self.pinnedSeparatorHeight
//            self.pinnedBackroundView.transform.ty = -self.pinnedTableViewHeightMinusFooter - self.pinnedSeparatorHeight
            self.updatePinnedTableBackgroundHeight(withOffset: 0)
            self.updateUnpinnedTableViewTop()
            self.layoutIfNeeded()
        }
        
        let completion: (Bool) -> Void = { _ in
            self.autoHidingPinnedPlaylists = false
            self.autoShowingPinnedPlaylists = false
            self.pinnedPlaylistsHidden = true
        }
        
        if spring {
            let options: UIViewAnimationOptions = [.BeginFromCurrentState, .LayoutSubviews, .AllowUserInteraction]
            UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: options, animations: animations, completion: completion)

        } else {
            UIView.animateWithDuration(0.4, animations: animations, completion: completion)
        }
        
        pinnedFooterView!.adjustImageToState(.Normal)
//        adjustUnpinnedPlaylistsContent(andScrollToTop: scrollUnpinnedToTop)
    }
    
    func adjustUnpinnedPlaylistsContent(andScrollToTop scrollToTop: Bool) {
        // Adjusts the unpinned playlist insets and offsets to be just below the "show pinned playlists" buttons
//        updateUnpinnedTableViewTop()
//        let options: UIViewAnimationOptions = [.BeginFromCurrentState, .LayoutSubviews, .AllowUserInteraction]
//        UIView.animateWithDuration(0.4, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: options, animations: {
//            self.unpinnedTableView.contentInset.top = self.currentTopBarHeight + self.pinnedTableView.contentSize.height + self.pinnedTableView.transform.ty
//            if scrollToTop { self.unpinnedTableView.contentOffset.y = -self.unpinnedTableView.contentInset.top + self.unpinnedTableView.tableHeaderView!.frame.height}
//            self.unpinnedTableView.scrollIndicatorInsets = self.unpinnedTableView.contentInset
//            }, completion: nil)
    }
    
    func adjustUnpinnedPlaylistsAfterPinning() {
//        updateUnpinnedTableViewTop()

//        if let normalRowHeight = pinnedTableView.delegate!.tableView?(pinnedTableView, heightForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) {
//            self.layoutIfNeeded()
//            let options: UIViewAnimationOptions = [.BeginFromCurrentState, .LayoutSubviews, .AllowUserInteraction]
//            UIView.animateWithDuration(0.4, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: options, animations: {
//                self.unpinnedTableView.contentInset.top = self.unpinnedTableView.contentInset.top + normalRowHeight
//                self.unpinnedTableView.contentOffset.y = -self.unpinnedTableView.contentInset.top
//                self.unpinnedTableView.scrollIndicatorInsets = self.unpinnedTableView.contentInset
//                self.updatePinnedTableBackgroundHeight(withOffset: normalRowHeight)
//                self.layoutIfNeeded()
//                }, completion: nil)
//        }
    }
    
    func adjustUnpinnedPlaylistsAfterUnpinning() {
//        updatePinnedTableBackgroundHeight(withOffset: 0)
//        updateUnpinnedTableViewTop()
//        if let normalRowHeight = pinnedTableView.delegate!.tableView?(pinnedTableView, heightForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) {
//            self.layoutIfNeeded()
//            let options: UIViewAnimationOptions = [.BeginFromCurrentState, .LayoutSubviews, .AllowUserInteraction]
//            UIView.animateWithDuration(0.4, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: options, animations: {
//                self.unpinnedTableView.contentInset.top = self.unpinnedTableView.contentInset.top - normalRowHeight
//                self.unpinnedTableView.contentOffset.y = -self.unpinnedTableView.contentInset.top
//                self.unpinnedTableView.scrollIndicatorInsets = self.unpinnedTableView.contentInset
//                self.updatePinnedTableBackgroundHeight(withOffset: -normalRowHeight)
//                self.layoutIfNeeded()
//                }, completion: nil)
//        }
    }

}



