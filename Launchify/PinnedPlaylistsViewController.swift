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
    
    // Model
    var unpinnedPlaylists = [LaunchifyPlaylist]()
//    var pinnedPlaylists = [LaunchifyPlaylist(playlistTitle: "First Pinned", uri: ""),
//                           LaunchifyPlaylist(playlistTitle: "Second Pinned", uri: ""),
//                           LaunchifyPlaylist(playlistTitle: "Third Pinned", uri: ""),
//                           LaunchifyPlaylist(playlistTitle: "Fourth Pinned", uri: ""),
//                           LaunchifyPlaylist(playlistTitle: "Fifth Pinned", uri: "")]
    var pinnedPlaylists = [LaunchifyPlaylist]()
    
    // Properties
    let transformKeyPath = "transform" // For Swift dynamic key/value observing
    
    var footerView: UIView?

    // MARK: View Controller Life Cycle
    override func loadView() {
        self.view = pinnedPlaylistsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUnpinnedTableView()
        configurePinnedTableView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Configure the initial appearance of the playlist view after everything has been loaded and the view is ready to appear
        pinnedPlaylistsView.configureInitialAppearance()
    }
    
    // MARK: - Configuration Methods
    func configurePinnedTableView() {
        pinnedPlaylists = LaunchifyPlaylistsManager.getPinnedPlaylists()
        pinnedPlaylistsView.pinnedTableView.reloadData()
        
        pinnedPlaylistsView.pinnedTableView.dataSource = self
        pinnedPlaylistsView.pinnedTableView.delegate = self
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
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Pinned Table View
        if tableView == pinnedPlaylistsView.pinnedTableView {
            return pinnedPlaylists.count
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
            let pinnedCell = tableView.dequeueReusableCellWithIdentifier(PlaylistTableViewCell.pinnedReuseIdentifier, forIndexPath: indexPath) as! PlaylistTableViewCell
            pinnedCell.configureCellWithPlaylist(pinnedPlaylists[indexPath.row])
            return pinnedCell
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
            return pinnedFooterView
        }
            
        // Unpinned Table View
        else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return tableView.sectionFooterHeight
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
            return true
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
    // -----------------------------------------------------------------------------------------------------------------------------------------^

    
    // Selection
    // -----------------------------------------------------------------------------------------------------------------------------------------v
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let pinnedTable = pinnedPlaylistsView.pinnedTableView
        let unpinnedTable = pinnedPlaylistsView.unpinnedTableView
        
        CATransaction.begin()
        CATransaction.setCompletionBlock() {
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
            LaunchifyPlaylistsManager.removePinnedPlaylist(playlist)
            pinnedPlaylists.removeAtIndex(indexPath.row)
            pinnedTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            pinnedPlaylistsView.adjustUnpinnedPlaylistsAfterUnpinning()
        }
            
        // Unpinned Table View
        else {
            // Show the pinned playlists (this will only occur if it was hidden)
            pinnedPlaylistsView.showPinnedPlaylists(withSpring: true, andScrollUnpinnedToTop: true)
            
            let playlist = unpinnedPlaylists[indexPath.row]
            
            // Add the pinned
            do {
                try LaunchifyPlaylistsManager.addPinnedPlaylist(playlist)
                
                pinnedPlaylists.append(playlist)
                let targetIndexPath = NSIndexPath(forRow: pinnedPlaylists.count - 1, inSection: 0)
                pinnedTable.insertRowsAtIndexPaths([targetIndexPath], withRowAnimation: .Top)
                
                // Remove the unpinned
                unpinnedPlaylists.removeAtIndex(indexPath.row)
                unpinnedTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Bottom)
                pinnedPlaylistsView.adjustUnpinnedPlaylistsAfterPinning()
                
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
        
//        UIView.animateWithDuration(0.03, animations: {
            self.footerView!.alpha = 0
//        })
        
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
            print(offsetY, threshold)
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