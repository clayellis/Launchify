//
//  NeedHelpViewController.swift
//  Launchify
//
//  Created by Clay Ellis on 4/8/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//

import UIKit

class NeedHelpViewController: PagingViewController {
    
    // View
    let needHelpView = NeedHelpView()
    
    // Model
    
    
    // Properties
    
    
    
    // MARK: View Controller Life Cycle
    override func loadView() {
        self.view = needHelpView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        needHelpView.logoutButton.addTarget(self, action: #selector(logoutTapped), forControlEvents: .TouchUpInside)
    }
    
    func logoutTapped(sender: UIButton) {
        SpotifyService.logout()
    }
    
}
