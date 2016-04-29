//
//  AccountViewController.swift
//  Launchify
//
//  Created by Clay Ellis on 4/8/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//

import UIKit
import SafariServices

class AccountViewController: PagingViewController {
    
    // View
    let accountView = AccountView()
    
    // Model
    
    
    // Properties
    
    
    
    // MARK: View Controller Life Cycle
    override func loadView() {
        self.view = accountView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureAccountTableView()
    }
    
    func configureAccountTableView() {
        accountView.tableView.dataSource = self
        accountView.tableView.delegate = self
        
        accountView.tableView.registerClass(AccountProfileCell.self, forCellReuseIdentifier: AccountProfileCell.reuseIdentifier)
        accountView.tableView.registerClass(AccountRateCell.self, forCellReuseIdentifier: AccountRateCell.reuseIdentifier)
        accountView.tableView.registerClass(AccountOptionCell.self, forCellReuseIdentifier: AccountOptionCell.reuseIdentifier)
    }
    
    func logoutTapped(sender: UIButton) {
        SpotifyService.logout()
    }
    
    func rateOnAppStore() {
        UIApplication.sharedApplication().openURL(kAppStoreRatingsURL)
    }
    
    func openMediumArticle() {
        if UIApplication.sharedApplication().canOpenURL(kMediumURL) {
            UIApplication.sharedApplication().openURL(kMediumURL)
        } else {
            let safariViewController = LFSafariViewController(URL: kMediumFallbackURL)
            safariViewController.delegate = self
            presentViewController(safariViewController, animated: true, completion: nil)
        }
    }
    
    func appsidianTapped(sender: UIButton) {
        let safariViewController = LFSafariViewController(URL: kAppsidianURL)
        safariViewController.delegate = self
        presentViewController(safariViewController, animated: true, completion: nil)
    }
}

extension AccountViewController: UITableViewDataSource, UITableViewDelegate {
    
    enum AccountCellType {
        case Profile, Rate, Onboarding, Medium
        
        static func accountCellForIndexPath(indexPath: NSIndexPath) -> AccountCellType {
            let section = indexPath.section
            let row = indexPath.row
            if section == 0 {
                if row == 0 {
                    return .Profile
                } else { // row == 1
                    return .Rate
                }
            } else { // section == 1
                if row == 0 {
                    return .Onboarding
                } else { // row == 1
                    return .Medium
                }
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return .min
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let accountCell = AccountCellType.accountCellForIndexPath(indexPath)
        switch accountCell {
        case .Profile: return 275
        case .Rate: return 50
        case .Onboarding, .Medium: return 60
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let accountCell = AccountCellType.accountCellForIndexPath(indexPath)
        switch accountCell {
        case .Profile:
            let profileCell = tableView.dequeueReusableCellWithIdentifier(AccountProfileCell.reuseIdentifier, forIndexPath: indexPath) as! AccountProfileCell
            profileCell.logoutButton.addTarget(self, action: #selector(logoutTapped), forControlEvents: .TouchUpInside)
            return profileCell
        case .Rate:
            let rateCell = tableView.dequeueReusableCellWithIdentifier(AccountRateCell.reuseIdentifier, forIndexPath: indexPath) as! AccountRateCell
            return rateCell
        case .Onboarding:
            let onboardingCell = tableView.dequeueReusableCellWithIdentifier(AccountOptionCell.reuseIdentifier, forIndexPath: indexPath) as! AccountOptionCell
            onboardingCell.textLabel?.text = "How to use Launchify"
            onboardingCell.imageView?.image = UIImage(named: "How_To_Use_Launchify_Icon")
            return onboardingCell
        case .Medium:
            let mediumCell = tableView.dequeueReusableCellWithIdentifier(AccountOptionCell.reuseIdentifier, forIndexPath: indexPath) as! AccountOptionCell
            mediumCell.textLabel?.text = "Why Launchify?"
            mediumCell.imageView?.image = UIImage(named: "Medium_Icon")
            return mediumCell
        }
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        } else {
            let appsidianButton = UIButton()
            appsidianButton.setImage(UIImage(named: "Appsidian"), forState: .Normal)
            appsidianButton.contentMode = .Center
            appsidianButton.addTarget(self, action: #selector(appsidianTapped), forControlEvents: .TouchUpInside)
            return appsidianButton
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return UITableViewAutomaticDimension
        } else {
            return 100
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let accountCell = AccountCellType.accountCellForIndexPath(indexPath)
        switch accountCell {
        case .Profile: break // Do nothing...
        case .Rate: rateOnAppStore()
        case .Onboarding: break // Present OnboardingViewController
        case .Medium: openMediumArticle()
        }
    }
}


extension AccountViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}




