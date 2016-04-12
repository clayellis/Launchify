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
    let unpinnedTableView = UITableView()
    var showPinnedPlaylistsCell: PinnedPlaylistShowTableViewCell? // Keep a reference to this cell to fade it in and out during animations
    
    // Stored Constraints
    
    
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
        let normalTopBarHeight = LFPagingController.sharedInstance.topBarBarHeight
        let topBarOffset = LFPagingController.sharedInstance.topBar.transform.ty
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
        addSubview(pinnedTableView)
        
        // Style View
        
        
        // Style Subviews
        pinnedTableView.contentInset = UIEdgeInsets(top: currentTopBarHeight, left: 0, bottom: 0, right: 0)
        pinnedTableView.contentOffset = CGPoint(x: 0, y: -currentTopBarHeight)
        pinnedTableView.showsVerticalScrollIndicator = false
        pinnedTableView.backgroundColor = .clearColor()
        pinnedTableView.separatorColor = .lfSeparatorGray()
        pinnedTableView.separatorInset = UIEdgeInsets(top: 0, left: 54, bottom: 0, right: 0)
        pinnedTableView.tableFooterView = UIView()
        pinnedTableView.delaysContentTouches = false
        
        unpinnedTableView.contentInset = UIEdgeInsets(top: currentTopBarHeight, left: 0, bottom: 0, right: 0)
        unpinnedTableView.contentOffset = CGPoint(x: 0, y: -currentTopBarHeight)
        unpinnedTableView.scrollIndicatorInsets = unpinnedTableView.contentInset
        unpinnedTableView.backgroundColor = .lfMediumGray()
        unpinnedTableView.separatorColor = .lfSeparatorGray()
        unpinnedTableView.separatorInset = UIEdgeInsets(top: 0, left: 54, bottom: 0, right: 0)
        unpinnedTableView.rowHeight = 60
        unpinnedTableView.delaysContentTouches = false
        
    }
    
    func configureLayout() {
        setTranslatesAutoresizingMaskIntoConstraintsToFalse([pinnedTableView, unpinnedTableView])
        
        // Add Constraints
        pinnedTableView.fillSuperview()
        unpinnedTableView.fillSuperview()
    }
    
    // MARK: - Animation Methods
    func hidePinnedPlaylists() {
//        forceTouchesEndedWhileAutoAnimating()
        
        // Adjust the content offset to hide the pinned playlist table
        let hiddenContentOffset = CGPoint(x: 0, y: pinnedTableViewHeightMinusLastRow - currentTopBarHeight)
        pinnedTableView.setContentOffset(hiddenContentOffset, animated: true)
        
        // Note: Content insets (setPinnedPlaylistInsetsToHiding()) are set automatically in scrollViewDidEndScrollingAnimation()
        
        // Fade in the the show pinned playlists cell
        UIView.animateWithDuration(0.2, delay: 0.2, options: [.BeginFromCurrentState], animations: {
            self.showPinnedPlaylistsCell?.alpha = 1
            }, completion: nil)
    }
    
    func showPinnedPlaylists() {
//        forceTouchesEndedWhileAutoAnimating()
        
        // Adjust the content offset to show the pinned playlist table
        let showingContentOffset = CGPoint(x: 0, y: -currentTopBarHeight)
        pinnedTableView.setContentOffset(showingContentOffset, animated: true)
        
        // Note: Content insets (setPinnedPlaylistInsetsToShowing()) are set automatically in scrollViewDidEndScrollingAnimation()
        
        UIView.animateWithDuration(0.1, animations: {
//            self.showPinnedPlaylistsCell?.alpha = 0
            }, completion: nil)
    }

    func setPinnedPlaylistInsetsToHiding() {
        UIView.animateWithDuration(0.4, animations: {
            let topInset = self.currentTopBarHeight - self.pinnedTableView.contentSize.height + self.pinnedTableViewLastRowHeight
            self.pinnedTableView.contentInset.top = topInset
            
            let bottomInset = self.pinnedTableView.frame.size.height - self.currentTopBarHeight - self.pinnedTableViewLastRowHeight
            self.pinnedTableView.contentInset.bottom = bottomInset
        })
    }
    
    func setPinnedPlaylistInsetsToShowing() {
        UIView.animateWithDuration(0.4, animations: {
            self.pinnedTableView.contentInset.top = self.currentTopBarHeight
            self.pinnedTableView.contentInset.bottom = 0
        })
    }
    
    func forceTouchesEndedWhileAutoAnimating() {
        pinnedTableView.panGestureRecognizer.enabled = false
        pinnedTableView.panGestureRecognizer.enabled = true
    }
}



