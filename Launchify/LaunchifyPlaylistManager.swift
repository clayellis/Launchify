//
//  LaunchifyPlaylistManager.swift
//  Launchify
//
//  Created by Clay Ellis on 4/8/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//

import UIKit

extension LaunchifyPlaylist {
    convenience init(sptPartialPlaylist playlist: SPTPartialPlaylist) {
        self.init(playlistTitle: playlist.name, uri: playlist.playableUri.absoluteString)
    }
}

class LaunchifyPlaylistsManager {
    
    /// Get playlists from Spotify
    // TODO: Make this method parse for playlists that are in the pinned playlists as well and strip them out
    class func getPlaylistsFromSpotify(completion: (playlists: [LaunchifyPlaylist]) -> ()) {
        let session = SPTAuth.defaultInstance().session
        var launchifyPlaylists = [LaunchifyPlaylist]()
        SPTPlaylistList.playlistsForUserWithSession(session) { (error, playlists) in
            if error != nil {
                print("Error getting playlists: \(error)")
            }
            
            // Success
            if let safePlaylists = playlists as? SPTPlaylistList,
                let spotifyPlaylists = safePlaylists.items as? [SPTPartialPlaylist] {
                // Cast each spotify playlist as our own launchify playlist type and store them in an array to return
                for spotifyPlaylist in spotifyPlaylists {
                    // TODO: See TODO above
                    launchifyPlaylists.append(LaunchifyPlaylist(sptPartialPlaylist: spotifyPlaylist))
                }
                
                completion(playlists: launchifyPlaylists)
            }
        }
        
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
    
    /// Add a playlist to the pinned playlists
    // TODO: This method unarchives and rearchives the entire list just to add one playlist, make it more efficient
    class func addPinnedPlaylist(playlist: LaunchifyPlaylist) {
        // Archive the playlist to be stored and then store it
        var pinnedPlaylists = LaunchifyPlaylistsManager.getPinnedPlaylists()
        pinnedPlaylists.append(playlist)
        LaunchifyPlaylistsManager.setPinnedPlaylists(pinnedPlaylists)
    }
    
    
    // TODO: Add a swapPlaylistsAtIndexes method (to handle rearranging)
    
}

