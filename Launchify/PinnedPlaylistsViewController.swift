//
//  PinnedPlaylistsViewController.swift
//  Launchify
//
//  Created by Clay Ellis on 4/8/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//

import UIKit

// Global context variable for key/value observing
private var pagingContext = 0

class PinnedPlaylistsViewController: UIViewController, LFPagingControllerPagingDelegate {
    
    // View
    let pinnedPlaylistsView = PinnedPlaylistsView()
    
    // Model
    var unpinnedPlaylists = [LaunchifyPlaylist]()
    var pinnedPlaylists = [LaunchifyPlaylist(playlistTitle: "First Pinned", uri: ""),
                           LaunchifyPlaylist(playlistTitle: "Second Pinned", uri: ""),
                           LaunchifyPlaylist(playlistTitle: "Third Pinned", uri: ""),
                           LaunchifyPlaylist(playlistTitle: "Fourth Pinned", uri: ""),
                           LaunchifyPlaylist(playlistTitle: "Fifth Pinned", uri: "")]
    
    // Properties
    let transformKeyPath = "transform"
    
    // States
    /// The system automatically sets pinnedPlaylistsHidden in the scrollViewDidEndScrollingAnimation(_:) method
    var pinnedPlaylistsHidden = false
    /// 
//    var autoAnimatingPinnedPlaylists = false
    /// Only set to true in the convenience (show/hid)PinnedPlaylist method
    /// Automatically reset by the system in scrollViewDidEndScrollingAnimation(_:)
    var autoShowingPinnedPlaylists = false
    /// Only set to true in the convenience (show/hid)PinnedPlaylist method
    /// Automatically reset by the system in scrollViewDidEndScrollingAnimation(_:)
    var autoHidingPinnedPlaylists = false
    
    
    // MARK: View Controller Life Cycle
    override func loadView() {
        self.view = pinnedPlaylistsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUnpinnedTableView()
        configurePinnedTableView()
    }
    
    // MARK: - Configuration Methods
    func configurePinnedTableView() {
        pinnedPlaylistsView.pinnedTableView.dataSource = self
        pinnedPlaylistsView.pinnedTableView.delegate = self
        pinnedPlaylistsView.pinnedTableView.registerClass(PlaylistTableViewCell.self,
                                                          forCellReuseIdentifier: PlaylistTableViewCell.pinnedReuseIdentifier)
        pinnedPlaylistsView.pinnedTableView.registerClass(PinnedPlaylistShowTableViewCell.self,
                                                          forCellReuseIdentifier: PinnedPlaylistShowTableViewCell.reuseIdentifier)
        LFPagingController.sharedInstance.topBar.addObserver(self, forKeyPath: transformKeyPath, options: .New, context: &pagingContext)
        LFPagingController.sharedInstance.addPagingDelegate(self)
    }
    
    func configureUnpinnedTableView() {
        // Get the initial data
        LaunchifyPlaylistsManager.getPlaylistsFromSpotify { (playlists) in
            self.unpinnedPlaylists = playlists
            self.pinnedPlaylistsView.unpinnedTableView.reloadData()
        }
        
        pinnedPlaylistsView.unpinnedTableView.dataSource = self
        pinnedPlaylistsView.unpinnedTableView.delegate = self
        pinnedPlaylistsView.unpinnedTableView.registerClass(PlaylistTableViewCell.self,
                                                            forCellReuseIdentifier: PlaylistTableViewCell.unpinnedReuseIdentifier)
    }
    
    // MARK: - Observing Top Bar
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &pagingContext {
            guard let ty = change?[NSKeyValueChangeNewKey]?.CGAffineTransformValue().ty else { return }
            pagingControllerTopBarTYDidChange(newTy: ty)
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }

    func pagingControllerTopBarTYDidChange(newTy ty: CGFloat) {
        let normalTopBarHeight = LFPagingController.sharedInstance.topBarBarHeight
        let topInset = normalTopBarHeight + ty
        var hiddenOffset: CGFloat = 0
        print("pagingControllerTopBarTYDidChange")

        if pinnedPlaylistsHidden {
            print("^ (if pinnedPlaylistsHidden)")
            hiddenOffset = pinnedPlaylistsView.pinnedTableViewHeightMinusLastRow
            
            let bottomInset = pinnedPlaylistsView.pinnedTableView.frame.size.height - pinnedPlaylistsView.currentTopBarHeight - pinnedPlaylistsView.pinnedTableViewLastRowHeight
            pinnedPlaylistsView.pinnedTableView.contentInset.bottom = bottomInset
        }

        pinnedPlaylistsView.pinnedTableView.contentInset.top = topInset - hiddenOffset
    }
    
    deinit {
        LFPagingController.sharedInstance.topBar.removeObserver(self, forKeyPath: transformKeyPath, context: &pagingContext)
    }
    
    // MARK: - Pinned Table View Show/Hide Methods
    func pagingControll(affectingScrollViewDidScrollPastThresholdWithOffset offset: CGFloat, draggingUp: Bool) {
        print("pagingControllAffectingScrollViewDidScrollPastThresholdWithOffset")

        let showHideThreshold: CGFloat = 120
        if draggingUp && offset > showHideThreshold && !pinnedPlaylistsHidden {
            print("pagingControllAffectingScrollViewDidScrollPastThresholdWithOffset - if")
            hidePinnedPlaylists()
        } else if !draggingUp && offset > showHideThreshold && pinnedPlaylistsHidden {
            print("pagingControllAffectingScrollViewDidScrollPastThresholdWithOffset - else if")
            showPinnedPlaylists()
        }
    }
    
    func showPinnedPlaylistsTapped(sender: UIButton) {
        print("showPinnedPlaylistsTapped")
        if pinnedPlaylistsHidden {
            print("showPinnedPlaylistsTapped - if pinnedPlaylistsHidden")
            showPinnedPlaylists()
        } else {
            print("showPinnedPlaylistsTapped - else !pinnedPlaylistsHidden")
            hidePinnedPlaylists()
        }
    }
    
    func showPinnedPlaylists() {
        print("showPinnedPlaylists()")
//        autoAnimatingPinnedPlaylists = true
        autoShowingPinnedPlaylists = true
        autoHidingPinnedPlaylists = false
        pinnedPlaylistsView.showPinnedPlaylists()
    }
    
    func hidePinnedPlaylists() {
        print("hidePinnedPlaylists()")
        
//        autoAnimatingPinnedPlaylists = true
        autoHidingPinnedPlaylists = true
        autoShowingPinnedPlaylists = false
        pinnedPlaylistsView.hidePinnedPlaylists()
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
                let cell = tableView.dequeueReusableCellWithIdentifier(PlaylistTableViewCell.pinnedReuseIdentifier)
                let pinnedCell = (cell as? PlaylistTableViewCell) ?? PlaylistTableViewCell()
                pinnedCell.configureCellWithPlaylist(pinnedPlaylists[indexPath.row])
                return pinnedCell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier(PinnedPlaylistShowTableViewCell.reuseIdentifier)
                let showPinnedPlaylistsCell = (cell as? PinnedPlaylistShowTableViewCell) ?? PinnedPlaylistShowTableViewCell()
                showPinnedPlaylistsCell.showPinnedPlaylistsButton.addTarget(self, action: #selector(showPinnedPlaylistsTapped(_:)), forControlEvents: .TouchUpInside)
                pinnedPlaylistsView.showPinnedPlaylistsCell = showPinnedPlaylistsCell
                return showPinnedPlaylistsCell
            }
        }
        
        // Unpinned Table View
        else {
            // TODO: Test this to see if the nil coellece (sp?) operator is necessary
            let cell = tableView.dequeueReusableCellWithIdentifier(PlaylistTableViewCell.unpinnedReuseIdentifier)
            let playlistCell = (cell as? PlaylistTableViewCell) ?? PlaylistTableViewCell()
            playlistCell.configureCellWithPlaylist(unpinnedPlaylists[indexPath.row])
            return playlistCell
        }
    }
    
    // MARK: Delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        // Pinned Table View
        if tableView == pinnedPlaylistsView.pinnedTableView {
            let playlist = pinnedPlaylists[indexPath.row]
            
            // Remove the pinned
            
            // TODO: Write the removePinnedPlaylist method on the playlist manager
//            LaunchifyPlaylistsManager.addPinnedPlaylist(<#T##playlist: LaunchifyPlaylist##LaunchifyPlaylist#>)
            pinnedPlaylists.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Bottom)
            
            // Add the unpinned
            unpinnedPlaylists.append(playlist)
            let targetIndexPath = NSIndexPath(forRow: pinnedPlaylists.count, inSection: 0)
            pinnedPlaylistsView.unpinnedTableView.insertRowsAtIndexPaths([targetIndexPath], withRowAnimation: .Top)
        }
            
        // Unpinned Table View
        else {
            let playlist = unpinnedPlaylists[indexPath.row]
            
            // Remove the unpinned
            unpinnedPlaylists.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Bottom)
            
            // Add the pinned
            LaunchifyPlaylistsManager.addPinnedPlaylist(playlist)
            pinnedPlaylists.append(playlist)
            let targetIndexPath = NSIndexPath(forRow: pinnedPlaylists.count - 1, inSection: 0)
            pinnedPlaylistsView.pinnedTableView.insertRowsAtIndexPaths([targetIndexPath], withRowAnimation: .Top)
        }
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        
        
        // Pinned Table View
        if tableView == pinnedPlaylistsView.pinnedTableView {
            
        }
            
        // Unpinned Table View
        else {
            
        }
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! PlaylistTableViewCell
        cell.didHighlight()
    }
    
    func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        
        
        // Pinned Table View
        if tableView == pinnedPlaylistsView.pinnedTableView {
            
        }
            
        // Unpinned Table View
        else {
            
        }
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! PlaylistTableViewCell
        cell.didUnhighlight()
    }
    
    // MARK: Scroll View Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let tableView = scrollView as! UITableView
        // Pinned Table View
        if tableView == pinnedPlaylistsView.pinnedTableView {
//            print("scrollViewDidScroll()")

            if !autoShowingPinnedPlaylists && !autoHidingPinnedPlaylists {
//                print("scrollViewDidScroll() - if !autoShowing/HidingPlaylists")
                tableView.contentInset.bottom = 0
                let offsetY = tableView.contentOffset.y
                if pinnedPlaylistsHidden {
//                    print("scrollViewDidScroll() - if !autoShowing/HidingPlaylists - if pinnedPlaylistsHidden")

                    let threshold: CGFloat = 100
                    let targetPoint = -tableView.contentInset.top - threshold
//                    print(offsetY, targetPoint)
                    if offsetY < targetPoint {
//                        print("scrollViewDidScroll() - if !autoShowing/HidingPlaylists - if pinnedPlaylistsHidden - if offset < targetPoint")
                        print("\nAuto show\n")
                        showPinnedPlaylists()
                    }
                } else {
//                    print("scrollViewDidScroll() - if !autoShowing/HidingPlaylists - else !pinnedPlaylistsHidden")

                    let threshold: CGFloat = 230
                    let adjustedBaseInset = pinnedPlaylistsView.currentTopBarHeight
                    let targetPoint = tableView.contentSize.height - adjustedBaseInset - threshold
//                    print(offsetY, targetPoint)
                    if offsetY > targetPoint {
//                        print("scrollViewDidScroll() - if !autoShowing/HidingPlaylists - else !pinnedPlaylistsHidden - if offset > targetPoint")
                        print("\nAuto hide\n")
                        hidePinnedPlaylists()
                    }
                }
            }
        }
            
        // Unpinned Table View
        else {
            LFPagingController.sharedInstance.affectingScrollViewDidScroll(scrollView)
        }
    
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let tableView = scrollView as! UITableView
        // Pinned Table View
        if tableView == pinnedPlaylistsView.pinnedTableView {
            print("scrollViewDidEndDragging()")
        }
            
        // Unpinned Table View
        else {
            
        }
        
        LFPagingController.sharedInstance.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        let tableView = scrollView as! UITableView
        // Pinned Table View
        if tableView == pinnedPlaylistsView.pinnedTableView {
            print("scrollViewDidEndDecelerating()")
        }
            
        // Unpinned Table View
        else {
            
        }
        
        LFPagingController.sharedInstance.scrollViewDidEndDecelerating(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        
        let tableView = scrollView as! UITableView
        // Pinned Table View
        if tableView == pinnedPlaylistsView.pinnedTableView {
            print("scrollViewDidEndScrollingAnimation()")
            if autoShowingPinnedPlaylists {
                print("scrollViewDidEndScrollingAnimation() - if autoShowingPinnedPlaylists")
                pinnedPlaylistsView.setPinnedPlaylistInsetsToShowing()
                pinnedPlaylistsView.forceTouchesEndedWhileAutoAnimating()
                autoShowingPinnedPlaylists = false
                autoHidingPinnedPlaylists = false
                pinnedPlaylistsHidden = false
            }
            
            // FIXME: Flicking the pinned playlist down will cause a weird flicker. "Auto show" and "Auto hide" are being printed right after
            // each other which means that a block (with those print statements) is being entered where it shouldn't
            
            if autoHidingPinnedPlaylists {
                print("scrollViewDidEndScrollingAnimation() - if autoHidingPinnedPlaylists")
                pinnedPlaylistsView.setPinnedPlaylistInsetsToHiding()
                pinnedPlaylistsView.forceTouchesEndedWhileAutoAnimating()
                autoHidingPinnedPlaylists = false
                autoShowingPinnedPlaylists = false
                pinnedPlaylistsHidden = true
            }
        }
            
        // Unpinned Table View
        else {
            
        }
        
        LFPagingController.sharedInstance.scrollViewDidEndScrollingAnimation(scrollView)
    }
}