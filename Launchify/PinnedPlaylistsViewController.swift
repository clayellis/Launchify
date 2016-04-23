//
//  PinnedPlaylistsViewController.swift
//  Launchify
//
//  Created by Clay Ellis on 4/8/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//

import UIKit

// Global context variable for Swift dynamic key/value observing
private var pagingContext = 0

class PinnedPlaylistsViewController: PagingViewController {
    
    // View
    let pinnedPlaylistsView = PinnedPlaylistsView()
    
    // Maintend View References
    var footerView: UIView?

    // Model
//    var pinnedPlaylists = [LaunchifyPlaylist]()
    var pinnedPlaylists : [LaunchifyPlaylist] = [LaunchifyPlaylist(playlistTitle: "Number One", uri: ""),
                                                 LaunchifyPlaylist(playlistTitle: "Number Two", uri: "")]
    var emptyPinnedPlaylistsData: [LaunchifyPlaylist] = [LaunchifyPlaylist(playlistTitle: "Kelsey's Mix", uri: ""),
                                                         LaunchifyPlaylist(playlistTitle: "Camping With The Crew", uri: "")]
    
    // TDOO: Consider caching these playlists for quick loading (still check for new playlists and graciously insert them)
    var unpinnedPlaylists = [LaunchifyPlaylist]()
    
    // Properties
    let transformKeyPath = "transform" // For Swift dynamic key/value observing

    // MARK: View Controller Life Cycle
    override func loadView() {
        self.view = pinnedPlaylistsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUnpinnedTableView()
        configurePinnedTableView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Configure the initial appearance of the playlist view after everything has been loaded and the view has appeared
        pinnedPlaylistsView.configureInitialAppearance()
    }
    
    // MARK: - Configuration Methods
    func configurePinnedTableView() {
//        pinnedPlaylists = LaunchifyPlaylistsManager.getPinnedPlaylists()
//        pinnedPlaylistsView.pinnedTableView.reloadData()
        
        pinnedPlaylistsView.pinnedTableView.dataSource = self
        pinnedPlaylistsView.pinnedTableView.delegate = self
        
        pinnedPlaylistsView.pinnedTableView.registerClass(
            PinnedExplanationCell.self, forCellReuseIdentifier: PinnedExplanationCell.reuseIdentifier)
        
        pinnedPlaylistsView.pinnedTableView.registerClass(
            PlaylistTableViewCell.self, forCellReuseIdentifier: PlaylistTableViewCell.pinnedReuseIdentifier)
        
        pinnedPlaylistsView.pinnedTableView.registerClass(
            PinnedPlaylistFooterView.self, forHeaderFooterViewReuseIdentifier: PinnedPlaylistFooterView.reuseIdentifier)
    }
    
    func configureUnpinnedTableView() {
        // Get the initial data
        LaunchifyPlaylistsManager.getPlaylistsFromSpotify { (playlists) in
            self.unpinnedPlaylists = playlists
            self.pinnedPlaylistsView.unpinnedTableView.reloadData()
        }
        
        pinnedPlaylistsView.unpinnedTableView.dataSource = self
        pinnedPlaylistsView.unpinnedTableView.delegate = self
        pinnedPlaylistsView.unpinnedTableView.registerClass(
            PlaylistTableViewCell.self, forCellReuseIdentifier: PlaylistTableViewCell.unpinnedReuseIdentifier)
        pinnedPlaylistsView.unpinnedTableView.registerClass(
            UnpinnedTableHeaderView.self, forHeaderFooterViewReuseIdentifier: UnpinnedTableHeaderView.reuseIdentifier)
    }
    
    override func didMoveToPagingController(pagingController: LFPagingController) {
        super.didMoveToPagingController(pagingController)
        pinnedPlaylistsView.pagingController = pagingController
        // Attach the delegate (to receive delegate events)
        pagingController.addPagingDelegate(self)
        pagingController.addPagingDelegate(pinnedPlaylistsView)
        // Begin observing top bar changes
        pagingController.topBar.addObserver(self, forKeyPath: transformKeyPath, options: .New, context: &pagingContext)
    }
    
    // MARK: - Observing Top Bar
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &pagingContext {
            guard let ty = change?[NSKeyValueChangeNewKey]?.CGAffineTransformValue().ty else { return }
            pinnedPlaylistsView.pagingControllerTopBarTYDidChange(newTy: ty)
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }

    deinit {
        pagingController!.topBar.removeObserver(self, forKeyPath: transformKeyPath, context: &pagingContext)
    }
}


// MARK: - LFPagingControllerPagingDelegate
extension PinnedPlaylistsViewController: LFPagingControllerPagingDelegate {
    func pagingControll(pageDidChangeToPageAtIndex index: Int) {
        // Current Index
        if index == 0 {
            // Show the pinned playlists and scroll to the top to give context
            pinnedPlaylistsView.showPinnedPlaylists(withSpring: true, andScrollUnpinnedToTop: true)
        }
    }
}


// MARK: - UITableView(DataSource/Delegate)
extension PinnedPlaylistsViewController: UITableViewDataSource, UITableViewDelegate, LFPagingControllerAffectingScrollView {
    
    // MARK: Header
    // -----------------------------------------------------------------------------------------------------------------------------------------v
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Pinned Table View
        if tableView == pinnedPlaylistsView.pinnedTableView {
            return nil
        }
            
        // Unpinned Table View
        else {
            return tableView.dequeueReusableHeaderFooterViewWithIdentifier(UnpinnedTableHeaderView.reuseIdentifier)
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.sectionHeaderHeight
    }
    // -----------------------------------------------------------------------------------------------------------------------------------------^
    
    
    // MARK: Rows
    // -----------------------------------------------------------------------------------------------------------------------------------------v
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if tableView == pinnedPlaylistsView.pinnedTableView {
            return 2
        }
            
        // Unpinned Table View
        else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Pinned Table View
        if tableView == pinnedPlaylistsView.pinnedTableView {
            if section == 0 {
                if pinnedPlaylists.count == 0 {
                    // Empty state
                    pinnedPlaylistsView.showEmptyUI()
                    return emptyPinnedPlaylistsData.count + 1
                } else {
                    return 0
                }
            } else {
                // Non-Empty State
                pinnedPlaylistsView.hideEmptyUI()
                return pinnedPlaylists.count
            }
        }
            
        // Unpinned Table View
        else {
            return unpinnedPlaylists.count
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.rowHeight
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Pinned Table View
        if tableView == pinnedPlaylistsView.pinnedTableView {
            if pinnedPlaylists.count == 0 {
                // Empty state
                if indexPath.row == 0 {
                    let explanationCell = tableView.dequeueReusableCellWithIdentifier(PinnedExplanationCell.reuseIdentifier, forIndexPath: indexPath) as! PinnedExplanationCell
                    explanationCell.contentView.alpha = 1 // Could have been set to 0 in pinnedPlaylistView.fadeOutCellForRowAtIndexPath()
                    return explanationCell
                } else {
                    let emptyPinnedCell = tableView.dequeueReusableCellWithIdentifier(PlaylistTableViewCell.pinnedReuseIdentifier, forIndexPath: indexPath) as! PlaylistTableViewCell
                    emptyPinnedCell.configureCellWithPlaylist(emptyPinnedPlaylistsData[indexPath.row - 1])
                    emptyPinnedCell.makeFake(true)
                    return emptyPinnedCell
                }
            } else {
                // Non-Empty State
                let pinnedCell = tableView.dequeueReusableCellWithIdentifier(PlaylistTableViewCell.pinnedReuseIdentifier, forIndexPath: indexPath) as! PlaylistTableViewCell
                pinnedCell.configureCellWithPlaylist(pinnedPlaylists[indexPath.row])
                pinnedCell.makeFake(false)
                return pinnedCell
            }
        }
        
        // Unpinned Table View
        else {
            let playlistCell = tableView.dequeueReusableCellWithIdentifier(PlaylistTableViewCell.unpinnedReuseIdentifier, forIndexPath: indexPath) as! PlaylistTableViewCell
            playlistCell.configureCellWithPlaylist(unpinnedPlaylists[indexPath.row])
            return playlistCell
        }
    }
    // -----------------------------------------------------------------------------------------------------------------------------------------^
    
    
    // MARK: Footer
    // -----------------------------------------------------------------------------------------------------------------------------------------v
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        // Pinned Table View
        if tableView == pinnedPlaylistsView.pinnedTableView {
            let pinnedFooterView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(PinnedPlaylistFooterView.reuseIdentifier) as! PinnedPlaylistFooterView
            // Using a tap gesture recognizer instead of a UIButton so we can still receive scrolling touches
            let handleTapGestureRecognizer = UITapGestureRecognizer(target: pinnedPlaylistsView, action: #selector(pinnedPlaylistsView.showPinnedPlaylistsTapped(_:)))
            pinnedFooterView.addGestureRecognizer(handleTapGestureRecognizer)
            pinnedPlaylistsView.pinnedFooterView = pinnedFooterView
            return section == 0 ? nil : pinnedFooterView
        }
            
        // Unpinned Table View
        else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : tableView.sectionFooterHeight
    }
    
    func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        // Only the pinned table has a footer, no need to check which table is being used
        // Fade the footer view in
        footerView = view
        footerView!.alpha = 0
        UIView.animateWithDuration(0.2, animations: {
            self.footerView!.alpha = 1
        })
    }
    // -----------------------------------------------------------------------------------------------------------------------------------------^
    
    
    // MARK: Reordering 
    // -----------------------------------------------------------------------------------------------------------------------------------------v
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Pinned Table View
        if tableView == pinnedPlaylistsView.pinnedTableView {
            if pinnedPlaylists.count == 0 {
                // Empty State - everything but the first row should show the reorder control
                return indexPath.row > 0
            } else {
                // Non-Empty State
                return true
            }
        }
            
        // Unpinned Table View
        else {
            return false
        }
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .None
    }
    
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        // Only the pinned table can move rows, no need to check which table is being used
        pinnedPlaylists.shift(sourceIndex: sourceIndexPath.row, destinationIndex: destinationIndexPath.row)
        LaunchifyPlaylistsManager.setPinnedPlaylists(pinnedPlaylists)
    }
    
    func tableView(tableView: UITableView, willBeginReorderingRowAtIndexPath indexPath: NSIndexPath) {
        // Hide the footer view so the moving row will be shown over it
        pinnedPlaylistsView.pinnedFooterView!.alpha = 0
    }
    
    func tableView(tableView: UITableView, didEndReorderingRowAtIndexPath indexPath: NSIndexPath) {
        // Show the footer view again
        pinnedPlaylistsView.pinnedFooterView!.alpha = 1
    }
    
    func tableView(tableView: UITableView, didCancelReorderingRowAtIndexPath indexPath: NSIndexPath) {
        // Show the footer view again
        pinnedPlaylistsView.pinnedFooterView!.alpha = 1
    }
    // -----------------------------------------------------------------------------------------------------------------------------------------^

    
    // MARK: Selection
    // -----------------------------------------------------------------------------------------------------------------------------------------v
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let pinnedTable = pinnedPlaylistsView.pinnedTableView
        let unpinnedTable = pinnedPlaylistsView.unpinnedTableView
        
        CATransaction.begin()
        CATransaction.setCompletionBlock() {
            // Forces the pinned footer view to be reloaded at the bottom of its section (instead of the bottom of the screen)
            pinnedTable.reloadData()
        }
        
        // Pinned Table View
        if tableView == pinnedPlaylistsView.pinnedTableView {
            let playlist = pinnedPlaylists[indexPath.row]
            
            // Add the unpinned
            unpinnedPlaylists.append(playlist)
            let targetIndexPath = NSIndexPath(forRow: pinnedPlaylists.count, inSection: 0)
            unpinnedTable.insertRowsAtIndexPaths([targetIndexPath], withRowAnimation: .Top)
            
            // Remove the pinned
            pinnedTable.beginUpdates()
            LaunchifyPlaylistsManager.removePinnedPlaylist(playlist)
            pinnedPlaylists.removeAtIndex(indexPath.row)
            
            if pinnedPlaylists.count == 0 {
                pinnedTable.insertRowsAtIndexPaths([
                    NSIndexPath(forRow: 0, inSection: 0),
                    NSIndexPath(forRow: 1, inSection: 0),
                    NSIndexPath(forRow: 2, inSection: 0)
                    ], withRowAnimation: .Automatic)
                pinnedPlaylistsView.adjustConstraintsForEmptyUI()
            } else {
                pinnedPlaylistsView.adjustConstraintsAfterUnpinning()
            }
            
            pinnedTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
            pinnedTable.endUpdates()
        }
            
        // Unpinned Table View
        else {
            // Show the pinned playlists (this will only occur if it was hidden)
            pinnedPlaylistsView.showPinnedPlaylists(withSpring: true, andScrollUnpinnedToTop: true)
            
            let playlist = unpinnedPlaylists[indexPath.row]
            
            // Add the pinned
            do {
                try LaunchifyPlaylistsManager.addPinnedPlaylist(playlist)
                
                pinnedTable.beginUpdates()
                
                if pinnedPlaylists.count == 0 {
                    pinnedPlaylistsView.fadeOutCellForRowInTableView(pinnedTable, atIndexPath: NSIndexPath(forRow: 0, inSection: 0))
                    pinnedTable.deleteRowsAtIndexPaths([
                        NSIndexPath(forRow: 0, inSection: 0),
                        NSIndexPath(forRow: 1, inSection: 0),
                        NSIndexPath(forRow: 2, inSection: 0)
                        ], withRowAnimation: .Automatic)
                    pinnedPlaylistsView.adjustConstraintsAfterEmptyUI()
                } else {
                    pinnedPlaylistsView.adjustConstraintsAfterPinning()
                }
                
                pinnedPlaylists.append(playlist)
                let targetIndexPath = NSIndexPath(forRow: pinnedPlaylists.count - 1, inSection: 1)
                pinnedTable.insertRowsAtIndexPaths([targetIndexPath], withRowAnimation: .Top)
                pinnedTable.endUpdates()
                
                // Remove the unpinned
                unpinnedPlaylists.removeAtIndex(indexPath.row)
                unpinnedTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Bottom)
                
                
            } catch LaunchifyError.FreeLimitReached {
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                
                let alert = UIAlertController(title: "Limit Reached", message: "Bump your playlist limit to 5 for $1", preferredStyle: .Alert)
                
                let upgradeAction = UIAlertAction(title: "Upgrade", style: .Default) {
                    action in
                    LaunchifyPlaylistsManager.increasePlaylistLimit()
                }
                
                let cancelAction = UIAlertAction(title: "I'll Upgrade Later", style: .Cancel, handler: nil)
                
                alert.addAction(upgradeAction)
                alert.addAction(cancelAction)
                
                presentViewController(alert, animated: true, completion: nil)
                
                return print("Free limit reached")
            } catch LaunchifyError.PaidLimitReached {
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                return print("Paid limit reached")
            } catch {
                // Unexpected error
            }
        }
        
        footerView!.alpha = 0
        CATransaction.commit()
    }
    
    func unpinToggleButtonTapped(sender: UIButton) {
        
    }
    
    func pinToggleButtonTapped(sender: UIButton) {
        
    }
    // -----------------------------------------------------------------------------------------------------------------------------------------^
    
    
    // MARK: Highlighting
    // -----------------------------------------------------------------------------------------------------------------------------------------v
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! PlaylistTableViewCell
        cell.didHighlight()
    }
    
    
    func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! PlaylistTableViewCell
//        if !cell.selected {
            // TODO: Make this work so that when a user does selects a row it doesn't unhighlight
            cell.didUnhighlight()
//        }
    }
    // -----------------------------------------------------------------------------------------------------------------------------------------^
    
    
    // MARK: Scrolling (ScrollViewDelegate)
    // -----------------------------------------------------------------------------------------------------------------------------------------v
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let tableView = scrollView as! UITableView
        // Pinned Table View
        if tableView == pinnedPlaylistsView.pinnedTableView {
            pinnedPlaylistsView.pinnedPlaylistTableViewDidScroll()
            pinnedPlaylistsView.pinnedFooterView?.adjustImageToState(.Highlighted)
        }
            
        // Unpinned Table View
        else {
            pagingController?.affectingScrollViewDidScroll(scrollView)
            let offsetY = scrollView.contentOffset.y
            let threshold = -scrollView.contentInset.top - 100
            if offsetY < threshold {
                pinnedPlaylistsView.showPinnedPlaylists(withSpring: true, andScrollUnpinnedToTop: true)
            }
            
            
        }
    }
        
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let tableView = scrollView as! UITableView
        // Pinned Table View
        if tableView == pinnedPlaylistsView.pinnedTableView {
            pinnedPlaylistsView.pinnedFooterView?.adjustImageToState(.Normal)
        }
            
        // Unpinned Table View
        else {
            pagingController?.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let tableView = scrollView as! UITableView
        // Pinned Table View
        if tableView == pinnedPlaylistsView.pinnedTableView {
            pinnedPlaylistsView.pinnedFooterView?.adjustImageToState(.Normal)
        }
            
        // Unpinned Table View
        else {
            pagingController?.scrollViewDidEndDecelerating(scrollView)
        }
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        let tableView = scrollView as! UITableView
        // Pinned Table View
        if tableView == pinnedPlaylistsView.pinnedTableView {
            // ...
        }
            
        // Unpinned Table View
        else {
            pagingController?.scrollViewDidEndScrollingAnimation(scrollView)
        }
    }
    // -----------------------------------------------------------------------------------------------------------------------------------------^
    
}