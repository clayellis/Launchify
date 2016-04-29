//
//  LFSafariViewController.swift
//  Launchify
//
//  Created by Clay Ellis on 4/24/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//

import UIKit
import SafariServices

class LFSafariViewController: SFSafariViewController {
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .Fade
    }
}
