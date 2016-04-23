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
        
        // (Insets and offsets are set in configureInitialAppearance)
        unpinnedTableView.sectionHeaderHeight = 55
        unpinnedTableView.rowHeight = 60
        unpinnedTableView.sectionFooterHeight = 0
        unpinnedTableView.backgroundColor = .lfMediumGray()
        unpinnedTableView.separatorColor = .lfSeparatorGray()
        unpinnedTableView.separatorInset = UIEdgeInsets(top: 0, left: 54, bottom: 0, right: 0)
        unpinnedTableView.delaysContentTouches = false
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
        updatePinnedAndUnpinnedTableConstraints()
//        updatePinnedTableBackgroundHeight()
//        updateUnpinnedTableViewTopIfNeeded()
//        unpinnedTableView.contentOffset.y = -pinnedBackgroundViewHeight.constant - unpinnedTableView.tableHeaderView!.frame.height
//         Hide the empty UI
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
    }
    
    // MARK: - Empty UI
    func showEmptyUI() {
        UIView.animateWithDuration(0.7, animations: {
            self.pinnedExplanationView.alpha = 1
        })
    }
    
    func hideEmptyUI() {
        self.pinnedExplanationView.alpha = 0
    }
    
    // MARK: Constraint Updating
    
    // Convenience methods
    func updatePinnedAndUnpinnedTableConstraints(withOffset offset: CGFloat = 0) {
        // Automatically calls the update methods in the correct order, background height first, unpinned top second
        updatePinnedTableBackgroundHeight(withOffset: offset)
        updateUnpinnedTableViewTop(withOffset: offset)
    }
    
    // Constraint Updtaing Methods
    func updatePinnedTableBackgroundHeight(withOffset offset: CGFloat = 0) {
        pinnedBackgroundViewHeight.active = false
        pinnedBackgroundViewHeight.constant =
            currentTopBarHeight + pinnedTableView.contentSize.height + pinnedTableView.transform.ty + pinnedSeparatorHeight + offset
            - (pinnedTableView.contentOffset.y + pinnedTableView.contentInset.top)
        pinnedBackgroundViewHeight.active = true
    }
    
    func updateUnpinnedTableViewTop(withOffset offset: CGFloat = 0) {
        unpinnedTableViewTop.active = false
        unpinnedTableViewTop.constant =
            currentTopBarHeight + pinnedTableView.contentSize.height + pinnedTableView.transform.ty + pinnedSeparatorHeight + offset
        unpinnedTableViewTop.active = true
    }
    
}

// MARK: - Pinned Playlist Table Scrolling / Showing / Hiding Animation Methods
extension PinnedPlaylistsView: LFPagingControllerPagingDelegate {
    
    
    // MARK: LFPagingControllerPagingDelegate
    func pagingControllerTopBarTYDidChange(newTy ty: CGFloat) {
        // Currently not using newTy (we could, but it's more readable to use self.currentTopBarHeight instead)
        pinnedTableView.contentInset.top = currentTopBarHeight
        updatePinnedTableBackgroundHeight(withOffset: 0)
    }

    func pagingControll(pagingControl pagingControl: LFPagingController, affectingScrollViewDidScrollPastThreshold threshold: CGFloat, withOffset offset: CGFloat, draggingUp: Bool) {
        let hideThreshold: CGFloat = threshold + 45
        let showThreshold: CGFloat = threshold + 100
        if draggingUp && offset > hideThreshold && !pinnedPlaylistsHidden {
            hidePinnedPlaylists(withSpring: true, andScrollUnpinnedToTop: false)
            pagingControl.resetScrollingValues()
        } else if !draggingUp && offset > showThreshold && pinnedPlaylistsHidden {
            showPinnedPlaylists(withSpring: true, andScrollUnpinnedToTop: false)
            pagingControl.resetScrollingValues()
        }
    }
    
    
    // MARK: Scrolling
    func pinnedPlaylistTableViewDidScroll() {
        // Keep the background behind the pinned playlists
        updatePinnedTableBackgroundHeight()
        
        // Quickly open and close the pinned playlists based on state, velocity, and offset
        let offsetY = pinnedTableView.contentOffset.y + pinnedTableView.contentInset.top
        if !autoShowingPinnedPlaylists && !autoHidingPinnedPlaylists {
            let draggingUp = pinnedTableView.panGestureRecognizer.translationInView(pinnedTableView).y < 0
            let velocity = fabs(pinnedTableView.panGestureRecognizer.velocityInView(pinnedTableView).y)
            let velocityThreshold: CGFloat = 500
            let threshold: CGFloat = 65
            if pinnedPlaylistsHidden {
                if offsetY < -threshold || (!draggingUp && velocity > velocityThreshold) {
                    showPinnedPlaylists(withSpring: true, andScrollUnpinnedToTop: true)
                }
            } else {
                if offsetY > threshold || (draggingUp && velocity > velocityThreshold) {
                    hidePinnedPlaylists(withSpring: true, andScrollUnpinnedToTop: true)
                }
            }
        }
    }
    
    
    // MARK: Showing / Hiding
    func showPinnedPlaylistsTapped(sender: UIButton) {
        // Reset the scrolling values on the paging controller to prevent a opening and closing the pinned playlists in quick succession
        pagingController?.resetScrollingValues()
        
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
            self.updatePinnedAndUnpinnedTableConstraints()
            self.layoutIfNeeded()
        }
        
        let completion: (Bool) -> Void = { _ in
            self.autoShowingPinnedPlaylists = false
            self.autoHidingPinnedPlaylists = false
            self.pinnedPlaylistsHidden = false
        }
        
        if spring {
            let options: UIViewAnimationOptions = [.BeginFromCurrentState, .LayoutSubviews, .AllowUserInteraction]
            self.layoutIfNeeded()
            UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: options, animations: animations, completion: completion)
        } else {
            self.layoutIfNeeded()
            UIView.animateWithDuration(0.4, animations: animations, completion: completion)
        }
        
        pinnedFooterView!.adjustImageToState(.Normal)
    }
    
    func hidePinnedPlaylists(withSpring spring: Bool, andScrollUnpinnedToTop scrollUnpinnedToTop: Bool) {
        if autoHidingPinnedPlaylists || pinnedPlaylistsHidden { return }

        autoHidingPinnedPlaylists = true
        autoShowingPinnedPlaylists = false
        
        let animations: () -> Void = {
            self.pinnedTableView.transform.ty = -self.pinnedTableViewHeightMinusFooter - self.pinnedSeparatorHeight
            self.updatePinnedAndUnpinnedTableConstraints()
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
    }
    
    func adjustUnpinnedPlaylistsAfterPinning() {
        layoutIfNeeded()
        UIView.animateWithDuration(0.4, animations: {
            self.updatePinnedAndUnpinnedTableConstraints(withOffset: self.pinnedTableView.rowHeight)
            self.layoutIfNeeded()
        })
    }
    
    func adjustUnpinnedPlaylistsAfterUnpinning() {
        layoutIfNeeded()
        UIView.animateWithDuration(0.4, animations: {
            self.updatePinnedAndUnpinnedTableConstraints(withOffset: -self.pinnedTableView.rowHeight)
            self.layoutIfNeeded()
        })
    }

}



