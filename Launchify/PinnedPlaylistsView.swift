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
        return point.y < contentSize.height
    }
}

class PinnedPlaylistsView: UIView {
    
    // Subviews
    let pinnedTableView = PinnedTableView()
    let pinnedBackroundView = UIView()
    let unpinnedTableView = UITableView()
    var showPinnedPlaylistsCell: PinnedPlaylistShowTableViewCell? // Keep a reference to this cell to fade it in and out during animations
    
    // Stored Constraints
    var pinnedBackgroundViewHeight: NSLayoutConstraint!
    
    // Pinned Table Show/Hide Values
    var pinnedPlaylistsHidden = false
    var autoShowingPinnedPlaylists = false
    var autoHidingPinnedPlaylists = false
    
    
    // Convenience Values
    var pinnedTableViewHeightMinusLastRow: CGFloat {
        return pinnedTableView.contentSize.height - pinnedTableViewLastRowHeight
    }
    
    var pinnedTableViewLastRowHeight: CGFloat {
        let numberOfRows = pinnedTableView.numberOfRowsInSection(0)
        let lastRowIndexPath = NSIndexPath(forRow: numberOfRows - 1, inSection: 0)
        return pinnedTableView.delegate!.tableView!(pinnedTableView, heightForRowAtIndexPath: lastRowIndexPath)
    }
    
    var currentTopBarHeight: CGFloat {
//        return LFPagingController.sharedInstance.currentTopBarHeight()
        let normalTopBarHeight = LFPagingController.sharedInstance.topBarBarHeight
        let topBarOffset = LFPagingController.sharedInstance.topBar.transform.ty
        return normalTopBarHeight + topBarOffset // (+ because transform is always negative)
    }
    
    // MARK: - Initialization
    convenience init() {
        self.init(frame: .zero)
        LFPagingController.sharedInstance.addPagingDelegate(self)
        configureSubviews()
        configureLayout()
    }
    
    func configureSubviews() {
        // Add Subviews
        addSubview(unpinnedTableView)
        addSubview(pinnedBackroundView)
        addSubview(pinnedTableView)
        
        // Style View
        
        
        // Style Subviews
        pinnedBackroundView.backgroundColor = .lfDarkGray()
        
        // (Insets and offsets are set in configureInitialAppearance)
        pinnedTableView.showsVerticalScrollIndicator = false
        pinnedTableView.backgroundColor = .clearColor()
        pinnedTableView.separatorColor = .lfSeparatorGray()
        pinnedTableView.separatorInset = UIEdgeInsets(top: 0, left: 54, bottom: 0, right: 0)
        pinnedTableView.tableFooterView = UIView()
        pinnedTableView.delaysContentTouches = false
        
        // (Insets and offsets are set in configureInitialAppearance)
        unpinnedTableView.backgroundColor = .lfMediumGray()
        unpinnedTableView.separatorColor = .lfSeparatorGray()
        unpinnedTableView.separatorInset = UIEdgeInsets(top: 0, left: 54, bottom: 0, right: 0)
        unpinnedTableView.rowHeight = 60
        unpinnedTableView.delaysContentTouches = false
        
    }
    
    // Called from viewWillAppear()
    func configureInitialAppearance() {
        pinnedTableView.contentInset = UIEdgeInsets(top: currentTopBarHeight, left: 0, bottom: 0, right: 0)
        pinnedTableView.contentOffset.y = -pinnedTableView.contentInset.top
        
        // Force the pinned table view to load its data since adjustUpinnedPlaylistsContent relies on its content size
        pinnedTableView.reloadData()
        adjustUnpinnedPlaylistsContent()
    }
    
    func configureLayout() {
        setTranslatesAutoresizingMaskIntoConstraintsToFalse([pinnedBackroundView, pinnedTableView, unpinnedTableView])
        
        // Add Constraints
        pinnedBackgroundViewHeight = pinnedBackroundView.heightAnchor.constraintEqualToConstant(LFPagingController.sharedInstance.topBarBarHeight)

        NSLayoutConstraint.activateConstraints([
            pinnedBackroundView.leftAnchor.constraintEqualToAnchor(leftAnchor),
            pinnedBackroundView.rightAnchor.constraintEqualToAnchor(rightAnchor),
            pinnedBackroundView.topAnchor.constraintEqualToAnchor(topAnchor),
            pinnedBackgroundViewHeight
            ])
        pinnedTableView.fillSuperview()
        unpinnedTableView.fillSuperview()
    }
    
    func updatePinnedTableBackground(withOffset offset: CGFloat) {
        let newHeight = currentTopBarHeight + offset + 5 // + 5 to cover for spring animations
        if newHeight > currentTopBarHeight {
            pinnedBackgroundViewHeight.active = false
            pinnedBackgroundViewHeight.constant = newHeight
            pinnedBackgroundViewHeight.active = true
        }
    }
    
}

// MARK: - Pinned Playlist Table Scrolling / Showing / Hiding Animation Methods
extension PinnedPlaylistsView: LFPagingControllerPagingDelegate {
    
    // MARK: LFPagingControllerPagingDelegate
    func pagingControll(affectingScrollViewDidScrollPastThreshold threshold: CGFloat, withOffset offset: CGFloat, draggingUp: Bool) {
        let hideThreshold: CGFloat = threshold //+ 30
        let showThreshold: CGFloat = threshold + 100
        if draggingUp && offset > hideThreshold && !pinnedPlaylistsHidden {
            hidePinnedPlaylists(withSpring: true)
        } else if !draggingUp && offset > showThreshold && pinnedPlaylistsHidden {
            showPinnedPlaylists(withSpring: true)
        }
    }
    
    
    // MARK: Scrolling
    func pagingControllerTopBarTYDidChange(newTy ty: CGFloat) {
        // Currently not using newTy (we could, but it's more readable to use self.currentTopBarHeight instead)
        pinnedTableView.contentInset.top = currentTopBarHeight
        updatePinnedTableBackground(withOffset: ty)
    }
    
    func pinnedPlaylistTableViewDidScroll() {
        let offsetY = pinnedTableView.contentOffset.y + pinnedTableView.contentInset.top
        if !autoShowingPinnedPlaylists && !autoHidingPinnedPlaylists {
            let threshold: CGFloat = 90
            if pinnedPlaylistsHidden {
                if offsetY < -threshold {
                    showPinnedPlaylists(withSpring: false)
                }
            } else {
                if offsetY > threshold {
                    hidePinnedPlaylists(withSpring: false)
                }
            }
        }
        updatePinnedTableBackground(withOffset: -offsetY)
    }
    
    
    // MARK: Showing / Hiding
    func showPinnedPlaylistsTapped(sender: UIButton) {
        if pinnedPlaylistsHidden {
            showPinnedPlaylists(withSpring: true)
        } else {
            hidePinnedPlaylists(withSpring: true)
        }
    }
    
    // TODO: Document these methods
    func showPinnedPlaylists(withSpring spring: Bool) {
        if autoShowingPinnedPlaylists || !pinnedPlaylistsHidden { return }
        
        autoShowingPinnedPlaylists = true
        autoHidingPinnedPlaylists = false
        
        if spring {
            let options: UIViewAnimationOptions = [.BeginFromCurrentState, .LayoutSubviews, .AllowUserInteraction]
            UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: options, animations: {
                self.pinnedTableView.transform.ty = 0
                }, completion: { _ in
                    self.autoShowingPinnedPlaylists = false
                    self.autoHidingPinnedPlaylists = false
                    self.pinnedPlaylistsHidden = false
            })
            
        } else {
            UIView.animateWithDuration(0.3, animations: {
                self.pinnedTableView.transform.ty = 0
                }, completion: { _ in
                    self.autoShowingPinnedPlaylists = false
                    self.autoHidingPinnedPlaylists = false
                    self.pinnedPlaylistsHidden = false
            })
        }
        
        
        UIView.animateWithDuration(0.1, animations: {
//            self.showPinnedPlaylistsCell?.alpha = 0
            }, completion: nil)
        
        adjustUnpinnedPlaylistsContent()
    }
    
    func hidePinnedPlaylists(withSpring spring: Bool) {
        if autoHidingPinnedPlaylists || pinnedPlaylistsHidden { return }

        autoHidingPinnedPlaylists = true
        autoShowingPinnedPlaylists = false
        
        if spring {
            let options: UIViewAnimationOptions = [.BeginFromCurrentState, .LayoutSubviews, .AllowUserInteraction]
            UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: options, animations: {
                self.pinnedTableView.transform.ty = -self.pinnedTableViewHeightMinusLastRow
                }, completion: { _ in
                    self.autoHidingPinnedPlaylists = false
                    self.autoShowingPinnedPlaylists = false
                    self.pinnedPlaylistsHidden = true
            })

        } else {
            UIView.animateWithDuration(0.3, animations: {
                self.pinnedTableView.transform.ty = -self.pinnedTableViewHeightMinusLastRow
                }, completion: { _ in
                    self.autoHidingPinnedPlaylists = false
                    self.autoShowingPinnedPlaylists = false
                    self.pinnedPlaylistsHidden = true
            })
            
        }
        
        // Fade in the the show pinned playlists cell
        UIView.animateWithDuration(0.2, delay: 0.2, options: [.BeginFromCurrentState], animations: {
            self.showPinnedPlaylistsCell?.alpha = 1
            }, completion: nil)
        
        adjustUnpinnedPlaylistsContent()
    }
    
    func adjustUnpinnedPlaylistsContent() {
//        pinnedTableView.reloadData()
        // Adjusts the unpinned playlist insets and offsets to be just below the "show pinned playlists" buttons
        let options: UIViewAnimationOptions = [.BeginFromCurrentState, .LayoutSubviews, .AllowUserInteraction]
        UIView.animateWithDuration(0.4, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: options, animations: {
            self.unpinnedTableView.contentInset.top = self.currentTopBarHeight + self.pinnedTableView.contentSize.height + self.pinnedTableView.transform.ty
            self.unpinnedTableView.contentOffset.y = -self.unpinnedTableView.contentInset.top
            self.unpinnedTableView.scrollIndicatorInsets = self.unpinnedTableView.contentInset
            }, completion: nil)
    }
    
    func adjustUnpinnedPlaylistsAfterPinning() {
        if let normalRowHeight = pinnedTableView.delegate!.tableView?(pinnedTableView, heightForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) {
            let options: UIViewAnimationOptions = [.BeginFromCurrentState, .LayoutSubviews, .AllowUserInteraction]
            UIView.animateWithDuration(0.4, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: options, animations: {
                self.unpinnedTableView.contentInset.top = self.unpinnedTableView.contentInset.top + normalRowHeight
                self.unpinnedTableView.contentOffset.y = -self.unpinnedTableView.contentInset.top
                self.unpinnedTableView.scrollIndicatorInsets = self.unpinnedTableView.contentInset
                }, completion: nil)
        }
    }
    
    func adjustUnpinnedPlaylistsAfterUnpinning() {
        if let normalRowHeight = pinnedTableView.delegate!.tableView?(pinnedTableView, heightForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) {
            let options: UIViewAnimationOptions = [.BeginFromCurrentState, .LayoutSubviews, .AllowUserInteraction]
            UIView.animateWithDuration(0.4, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: options, animations: {
                self.unpinnedTableView.contentInset.top = self.unpinnedTableView.contentInset.top - normalRowHeight
                self.unpinnedTableView.contentOffset.y = -self.unpinnedTableView.contentInset.top
                self.unpinnedTableView.scrollIndicatorInsets = self.unpinnedTableView.contentInset
                }, completion: nil)
        }
    }
}



