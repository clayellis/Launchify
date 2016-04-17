// NOT WORKING

//
//  SpotifyService.swift
//  Launchify
//
//  Created by Clay Ellis on 4/16/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//

import Foundation

public final class SpotifyService {
    
    public class func configureAuth() {
        let auth = SPTAuth.defaultInstance()
        auth.clientID = kClientId
        auth.redirectURL = kDeepLinkRedirectURI
        auth.requestedScopes = [SPTAuthUserReadPrivateScope]
        auth.sessionUserDefaultsKey = authorizationSessionKey
        auth.tokenRefreshURL = NSURL(string: authorizationTokenRefreshURLString)
        auth.tokenSwapURL = NSURL(string: authorizationTokenSwapURLString)
    }
    
    public class func attemptRenewingSession(success success: () -> Void, failure: () -> Void) {
        let auth = SPTAuth.defaultInstance()
        if let sessionData = NSUserDefaults.standardUserDefaults().objectForKey(auth.sessionUserDefaultsKey) as? NSData,
            let session = NSKeyedUnarchiver.unarchiveObjectWithData(sessionData) as? SPTSession {
            
            if session.isValid() {

                // Session is still valid
                print("Session still valid")
                success()

            } else {
            
            // Renew the session
            SPTAuth.defaultInstance().renewSession(session, callback: { (error, renewedSession) in
                if error != nil {
                    print("Error renewing session \(error)")
                    return failure()
                }
                
                SPTAuth.defaultInstance().session = renewedSession
                print("Session renewed")
                return success()
                })
            }
            
        } else {
            print("User needs to login")
            failure()
        }
    }
    
    public class func login() {
        // AppDelegate will handle all UI updates
        UIApplication.sharedApplication().openURL(SPTAuth.defaultInstance().loginURL)
    }
    
    public class func logout() {
        // Remove the current Spotify session from user defaults
        NSUserDefaults.standardUserDefaults().removeObjectForKey(SPTAuth.defaultInstance().sessionUserDefaultsKey)
        // AppDelegate will handle all UI updates
        UIApplication.sharedApplication().openURL(kDeepLinkLogoutURI)

    }
}