//
//  MainViewController.swift
//  Launchify
//
//  Created by Clay Ellis on 4/3/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    // View
    let mainView = MainView()
    
    // Model
    
    
    // Properties
    
    
    // MARK: - View Controller Lifecycle
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add button targets
        mainView.loginButton.addTarget(self, action: #selector(loginButtonTapped(_:)), forControlEvents: .TouchUpInside)
    }
    
    // MARK: - Button Targets
    func loginButtonTapped(sender: UIButton) {
        let auth = SPTAuth.defaultInstance()
        auth.clientID = kClientId
        auth.redirectURL = kDeepLinkRedirectURI
        auth.requestedScopes = [SPTAuthUserReadPrivateScope]
        
        let loginURL = auth.loginURL
        UIApplication.sharedApplication().openURL(loginURL)
    }
}
