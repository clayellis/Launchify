//
//  LaunchifyPlaylistManagerExtension.swift
//  Launchify
//
//  Created by Clay Ellis on 4/17/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//

import Foundation

// Placing this extension here as this file is only available to the app target and we do not want to bog down the today widget target
extension LaunchifyPlaylist {
    convenience init(sptPartialPlaylist playlist: SPTPartialPlaylist) {
        self.init(playlistTitle: playlist.name, uri: playlist.playableUri.absoluteString)
    }
}

extension LaunchifyPlaylistsManager {
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
}