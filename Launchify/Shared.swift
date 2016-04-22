//
//  Shared.swift
//  Launchify
//
//  Created by Clay Ellis on 4/3/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//

import UIKit

// MARK: Application Constants
let kPlaylistFreeLimit = 3
let kPlaylistPaidLimit = 6
let kPlaylistPaidLimitPurchasedKey = "PlaylistIncreasedLimitPurchased"

// MARK: - Authorization Flow Keys
let authorizationSessionKey = "LaunchifySessionKey"
let authorizationTokenServiceScheme = "https://launchify-token-service.herokuapp.com"
//let authorizationTokenServiceScheme = "http://localhost:1234"
let authorizationTokenRefreshURLString = "\(authorizationTokenServiceScheme)/refresh"
let authorizationTokenSwapURLString = "\(authorizationTokenServiceScheme)/swap"

// MARK: Spotify Keys
let kClientId = "1e6f78f7c501481e83399edfcbfdcd82"
let kClientSecret = "589ea13d46b145619e96674b77a5a99b"

// MARK: - Shared Constants
let sharedUserDefaults = NSUserDefaults(suiteName: sharedUserDefaultsSuiteName)!
let sharedUserDefaultsSuiteName = "group.appsidian.LaunchifyTodayExtensionSharingDefaults"
let sharedPlaylistsArrayKey = "\(sharedUserDefaultsSuiteName).Playlists"

// MARK: - Deep Linking
let kAppScheme = "launchify://"
let kDeepLinkRedirectURI = NSURL(string:  "\(kAppScheme)returnafterlogin")!
let kDeepLinkLogoutURI = NSURL(string:  "\(kAppScheme)logout")!
let kDeepLinkEditURI = NSURL(string: "\(kAppScheme)/edit")!
let kValidDeepLinks = [kDeepLinkRedirectURI, kDeepLinkLogoutURI, kDeepLinkEditURI]


// ----------------------------------------------------------------------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------------------------------------------------------------------


// MARK: - Shared Classes
@objc (LaunchifyPlaylist)
class LaunchifyPlaylist: NSObject, NSCoding {
    
    // Properties
    var playlistTitle: String!
    var uri: String!
    
    init(playlistTitle: String, uri: String) {
        self.playlistTitle = playlistTitle
        self.uri = uri
        super.init()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let unarchivedPlaylistTitle = aDecoder.decodeObjectForKey("playlistTitle") as? String,
            let unarchivedURI = aDecoder.decodeObjectForKey("uri") as? String else {
            return nil
        }
        
        self.init(playlistTitle: unarchivedPlaylistTitle, uri: unarchivedURI)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.playlistTitle, forKey: "playlistTitle")
        aCoder.encodeObject(self.uri, forKey: "uri")
    }
}

func ==(lhs: LaunchifyPlaylist, rhs: LaunchifyPlaylist) -> Bool {
    return lhs.playlistTitle == rhs.playlistTitle && lhs.uri == rhs.uri
}