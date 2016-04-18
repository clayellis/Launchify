//
//  AppDelegate.swift
//  Launchify
//
//  Created by Clay Ellis on 4/3/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // For Testing --------------------------------------------------------------------------------------------------------
        var playlists = LaunchifyPlaylistsManager.getPinnedPlaylists()
        LaunchifyPlaylistsManager.resetPinnedPlaylists()
        playlists = LaunchifyPlaylistsManager.getPinnedPlaylists()
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: kPlaylistPaidLimitPurchasedKey)
        // --------------------------------------------------------------------------------------------------------------------
        
        // Configure the SPTAuth Object
        SpotifyService.configureAuth()
        
        // Continue loading application based on Spotify session state
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        // TODO: Set the window!.rootViewController to something else while loading
        
        SpotifyService.attemptRenewingSession(
            success: {
                self.showLaunchifyViewController()
            }, failure: {
                self.showLoginViewController()
        })
        
        return true
    }
    
    func activeSessionExists() -> Bool {
        return SPTAuth.defaultInstance().session != nil
    }
    
    func showLoginViewController() {
        window!.rootViewController?.removeFromParentViewController()
        window!.rootViewController = LoginViewController()
        window!.makeKeyAndVisible()
    }
    
    func showLaunchifyViewController() {
        window!.rootViewController?.removeFromParentViewController()
        window!.rootViewController = PagingContainerViewController()
        window!.makeKeyAndVisible()
    }
    
    // MARK: - Spotify Authorization Callbacks / Deeplinking
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        if SPTAuth.defaultInstance().canHandleURL(url) {
            return handleAuthCallbackWithURL(url)
        } else if kValidDeepLinks.contains(url) {
            return handleValidURL(url)
        } else { return false }
    }

    func handleAuthCallbackWithURL(url: NSURL) -> Bool {
        SPTAuth.defaultInstance().handleAuthCallbackWithTriggeredAuthURL(url, callback: { (error, session) in
            if error != nil {
                // TODO: Determine what to do in case of an error here
                return print("Auth error: \(error)")
            }
            
            // Login Successful
            print("Logged in")
            self.showLaunchifyViewController()
        })
        return true
    }
    
    func handleValidURL(url: NSURL) -> Bool {
        if url == kDeepLinkEditURI {
            print("Deep link to edit")
            return true
        } else if url == kDeepLinkLogoutURI {
            let rootViewController = window!.rootViewController!
            let loginViewController = LoginViewController()
            rootViewController.presentViewController(loginViewController, animated: true) {
                self.window!.rootViewController?.removeFromParentViewController()
                self.window!.rootViewController = loginViewController
            }
        }
        
        // Preserve this method for parsing deep links
//        let urlString = url.absoluteString
//        let components = urlString.componentsSeparatedByString("/")
//        let base = components[1]
//        if base == "edit" {
//            print("Valid edit url")
//        }
        return false
    }
    

    // MARK: - Not Being Used
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}

