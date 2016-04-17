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
            PinnedPlaylistShowTableViewCell.self, forCellReuseIdentifier: PinnedPlaylistShowTableViewCell.reuseIdentifier)
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

    // MARK: - Playlist Pin / Unpin Methods
    
    func unpinToggleButtonTapped(sender: UIButton) {
        
    }
    
    func pinToggleButtonTapped(sender: UIButton) {
        
    }

}


// MARK: - UITableView(DataSource/Delegate)
extension PinnedPlaylistsViewController: UITableViewDataSource, UITableViewDelegate, LFPagingControllerAffectingScrollView {
    
    // MARK: Data Source
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
        // Pinned Table View
        if tableView == pinnedPlaylistsView.pinnedTableView {
            return 0
        }
            
        // Unpinned Table View
        else {
            return 55
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Pinned Table View
        if tableView == pinnedPlaylistsView.pinnedTableView {
            return pinnedPlaylists.count + 1
        }
            
        // Unpinned Table View
        else {
            return unpinnedPlaylists.count
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // Pinned Table View
        if tableView == pinnedPlaylistsView.pinnedTableView {
            return indexPath.row < pinnedPlaylists.count ? 60 : 45
        }
            
        // Unpinned Table View
        else {
            return 60
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Pinned Table View
        if tableView == pinnedPlaylistsView.pinnedTableView {
            if indexPath.row < pinnedPlaylists.count {
                let pinnedCell = tableView.dequeueReusableCellWithIdentifier(
                    PlaylistTableViewCell.pinnedReuseIdentifier, forIndexPath: indexPath) as! PlaylistTableViewCell
                pinnedCell.configureCellWithPlaylist(pinnedPlaylists[indexPath.row])
//                pinnedCell.configureAsLastCell(indexPath.row == pinnedPlaylists.count - 1)
                return pinnedCell
            } else {
                let showPinnedPlaylistsCell = tableView.dequeueReusableCellWithIdentifier(
                    PinnedPlaylistShowTableViewCell.reuseIdentifier, forIndexPath: indexPath) as! PinnedPlaylistShowTableViewCell
                showPinnedPlaylistsCell.showPinnedPlaylistsButton.addTarget(
                    pinnedPlaylistsView, action: #selector(pinnedPlaylistsView.showPinnedPlaylistsTapped(_:)), forControlEvents: .TouchUpInside)
                pinnedPlaylistsView.showPinnedPlaylistsCell = showPinnedPlaylistsCell
                return showPinnedPlaylistsCell
            }
        }
        
        // Unpinned Table View
        else {
            let playlistCell = tableView.dequeueReusableCellWithIdentifier(PlaylistTableViewCell.unpinnedReuseIdentifier, forIndexPath: indexPath) as! PlaylistTableViewCell
            playlistCell.configureCellWithPlaylist(unpinnedPlaylists[indexPath.row])
            return playlistCell
        }
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Pinned Table View
        if tableView == pinnedPlaylistsView.pinnedTableView {
            return indexPath.row < pinnedPlaylists.count
        }
            
        // Unpinned Table View
        else {
            return false
        }
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        // Pinned Table View
        if tableView == pinnedPlaylistsView.pinnedTableView {
            // Fix the separator
//            adjustTableViewCellSeparatorsInTableView(tableView, sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)
            
            // Move the pinned playlists
            LaunchifyPlaylistsManager.swapPlaylistsAtIndexes(sourceIndex: sourceIndexPath.row, destinationIndex: destinationIndexPath.row)
        }
            
        // Unpinned Table View
        else {
            // ...
        }
    }
    
    // MARK: Delegate
    
    // Reordering
    func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        // Pinned Table View
        if tableView == pinnedPlaylistsView.pinnedTableView {
            var destinationIndexPath: NSIndexPath!
            let lastRow = tableView.numberOfRowsInSection(0) - 1
            if proposedDestinationIndexPath.row >= lastRow {
                destinationIndexPath = NSIndexPath(forRow: lastRow - 1, inSection: 0)
            } else {
                destinationIndexPath = proposedDestinationIndexPath
            }
            
            // Fix the separators
//            adjustTableViewCellSeparatorsInTableView(tableView, sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)
            
            return destinationIndexPath
        }
            
            // Unpinned Table View
        else {
            return sourceIndexPath
        }
    }
    
//    func adjustTableViewCellSeparatorsInTableView(tableView: UITableView, sourceIndexPath: NSIndexPath, destinationIndexPath: NSIndexPath) {
//        print(sourceIndexPath, destinationIndexPath)
//        let sourceCell = tableView.cellForRowAtIndexPath(sourceIndexPath) as! PlaylistTableViewCell
//        let destinationCell = tableView.cellForRowAtIndexPath(destinationIndexPath) as! PlaylistTableViewCell
//        sourceCell.configureAsLastCell(destinationIndexPath.row == pinnedPlaylists.count - 1)
//        destinationCell.configureAsLastCell(sourceIndexPath.row == pinnedPlaylists.count - 1)
//    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .None
    }
    
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    // Selection
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let pinnedTable = pinnedPlaylistsView.pinnedTableView
        let unpinnedTable = pinnedPlaylistsView.unpinnedTableView
        
        // Pinned Table View
        if tableView == pinnedPlaylistsView.pinnedTableView {
            let playlist = pinnedPlaylists[indexPath.row]
            
            // Remove the pinned
            LaunchifyPlaylistsManager.removePinnedPlaylist(playlist)
            pinnedTable.beginUpdates()
            pinnedPlaylists.removeAtIndex(indexPath.row)
            pinnedTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Bottom)
            pinnedTable.endUpdates()
            
            // Add the unpinned
            unpinnedPlaylists.append(playlist)
            let targetIndexPath = NSIndexPath(forRow: pinnedPlaylists.count, inSection: 0)
            unpinnedTable.beginUpdates()
            unpinnedTable.insertRowsAtIndexPaths([targetIndexPath], withRowAnimation: .Top)
            unpinnedTable.endUpdates()
            
            pinnedPlaylistsView.adjustUnpinnedPlaylistsAfterUnpinning()
        }
            
        // Unpinned Table View
        else {
            // Show the pinned playlists (this will only occur if it was hidden)
            pinnedPlaylistsView.showPinnedPlaylists(withSpring: true)
            
            let playlist = unpinnedPlaylists[indexPath.row]

            // Remove the unpinned
            unpinnedTable.beginUpdates()
            unpinnedPlaylists.removeAtIndex(indexPath.row)
            unpinnedTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Bottom)
            unpinnedTable.endUpdates()
            
            // Add the pinned
            LaunchifyPlaylistsManager.addPinnedPlaylist(playlist)
            pinnedPlaylists.append(playlist)
            let targetIndexPath = NSIndexPath(forRow: pinnedPlaylists.count - 1, inSection: 0)
            pinnedTable.beginUpdates()
            pinnedTable.insertRowsAtIndexPaths([targetIndexPath], withRowAnimation: .Top)
            pinnedTable.endUpdates()
            
            pinnedPlaylistsView.adjustUnpinnedPlaylistsAfterPinning()
        }
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        // Pinned Table View
        if tableView == pinnedPlaylistsView.pinnedTableView {
            // ...
        }
            
        // Unpinned Table View
        else {
            // ...
        }
        
        // FIXME: Crashed here once when the cell was a PinnedPlaylistShowTableViewCell
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! PlaylistTableViewCell
        cell.didHighlight()
    }
    
    func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        // Pinned Table View
        if tableView == pinnedPlaylistsView.pinnedTableView {
            // ...
        }
            
        // Unpinned Table View
        else {
            // ...
        }
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! PlaylistTableViewCell
//        if !cell.selected {
            // TODO: Make this work so that when a user does selects a row it doesn't unhighlight
            cell.didUnhighlight()
//        }
    }
    
    
    // MARK: Scroll View Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let tableView = scrollView as! UITableView
        // Pinned Table View
        if tableView == pinnedPlaylistsView.pinnedTableView {
            pinnedPlaylistsView.pinnedPlaylistTableViewDidScroll()
        }
            
        // Unpinned Table View
        else {
            pagingController?.affectingScrollViewDidScroll(scrollView)
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let tableView = scrollView as! UITableView
        // Pinned Table View
        if tableView == pinnedPlaylistsView.pinnedTableView {
            // ...
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
            // ...
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
}