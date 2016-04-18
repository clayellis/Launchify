//
//  LaunchifyPlaylistManager.swift
//  Launchify
//
//  Created by Clay Ellis on 4/8/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//

import Foundation


enum LaunchifyError: ErrorType {
    case FreeLimitReached
    case PaidLimitReached
}

// The following methods are found in LaunchifyPlaylistMangerExtension.swift in order to ensure target membership for this file includes both the Launchify and LaunchifyTodayExtension targets
//  - getPlaylistsFromSpotify

class LaunchifyPlaylistsManager {
    
    /// Get the current playlist limit based on whether the increased limit has been purchased or not
    class func currentPlaylistLimit() -> (limit: Int, paidLimit: Bool) {
        let purchased = NSUserDefaults.standardUserDefaults().boolForKey(kPlaylistPaidLimitPurchasedKey)
        return purchased ? (kPlaylistPaidLimit, true) : (kPlaylistFreeLimit, false)
    }
    
    /// Effectively increases the playlist limit by setting the paid playlist limit purchased key to true
    class func increasePlaylistLimit() {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: kPlaylistPaidLimitPurchasedKey)
    }

    /// Get archived playlists data from shared user defaults
    class func getPinnedPlaylistsArchived() -> [NSData] {
        if let archivedPlaylists = sharedUserDefaults.objectForKey(sharedPlaylistsArrayKey) as? [NSData] {
            return archivedPlaylists
        } else {
            return []
        }
    }
    
    /// Get pinned playlists
    class func getPinnedPlaylists() -> [LaunchifyPlaylist] {
        let archivedPlaylists = LaunchifyPlaylistsManager.getPinnedPlaylistsArchived()
        // Unarchive each of the archived playlists and return them in an array
        var pinnedPlaylists = [LaunchifyPlaylist]()
        for archivedPlaylist in archivedPlaylists {
            if let playlist = NSKeyedUnarchiver.unarchiveObjectWithData(archivedPlaylist) as? LaunchifyPlaylist {
                pinnedPlaylists.append(playlist)
            }
        }
        return pinnedPlaylists
    }

    /// Set the pinned playlists
    class func setPinnedPlaylists(playlists: [LaunchifyPlaylist]) {
        // Archive each of the playlists and store them in an array
        var archivedPlaylists = [NSData]()
        for playlist in playlists {
            let archivedPlaylist = NSKeyedArchiver.archivedDataWithRootObject(playlist)
            archivedPlaylists.append(archivedPlaylist)
        }
        // Save the archived playlists array in shared user defaults
        sharedUserDefaults.setObject(archivedPlaylists, forKey: sharedPlaylistsArrayKey)
        sharedUserDefaults.synchronize()
    }
    
    class func resetPinnedPlaylists() {
        setPinnedPlaylists([])
    }
    
    /// Add a playlist to the pinned playlists, throws an error if the limit has been reached
    // TODO: This method unarchives and rearchives the entire list just to add one playlist, make it more efficient
    class func addPinnedPlaylist(playlist: LaunchifyPlaylist) throws {
        // Archive the playlist to be stored and then store it
        var pinnedPlaylists = LaunchifyPlaylistsManager.getPinnedPlaylists()
        
        // Check if the limit has been reached, throw an error if so
        let limit = currentPlaylistLimit()
        if pinnedPlaylists.count == limit.limit {
            if limit.paidLimit {
                throw LaunchifyError.PaidLimitReached
            } else {
                throw LaunchifyError.FreeLimitReached
            }
        }
        
        pinnedPlaylists.append(playlist)
        LaunchifyPlaylistsManager.setPinnedPlaylists(pinnedPlaylists)
    }
    
    // TODO: Remove method
    class func removePinnedPlaylist(playlist: LaunchifyPlaylist) {
        var pinnedPlaylists = getPinnedPlaylists()
        for (index, pinnedPlaylist) in pinnedPlaylists.enumerate() {
            if playlist == pinnedPlaylist {
                pinnedPlaylists.removeAtIndex(index)
                break
            }
        }
        setPinnedPlaylists(pinnedPlaylists)
    }
    
    
    // TODO: Add a swapPlaylistsAtIndexes method (to handle rearranging)
    class func swapPlaylistsAtIndexes(sourceIndex sourceIndex: Int, destinationIndex: Int) {
        var playlists = getPinnedPlaylists()
        playlists.shift(sourceIndex: sourceIndex, destinationIndex: destinationIndex)
        setPinnedPlaylists(playlists)
    }
    
}

