//
//  LoginViewController.swift
//  Launchify
//
//  Created by Clay Ellis on 4/3/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    // View
    let loginView = LoginView()
    
    // Model
    
    
    // Properties
    
    
    // MARK: - View Controller Lifecycle
    override func loadView() {
        self.view = loginView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add button targets
        loginView.loginButton.addTarget(self, action: #selector(loginButtonTapped(_:)), forControlEvents: .TouchUpInside)
    }
    
    // MARK: - Button Targets
    func loginButtonTapped(sender: UIButton) {
        SpotifyService.login()
    }
}









