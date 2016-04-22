//
//  TodayViewController.swift
//  LaunchifyTodayExtension
//
//  Created by Clay Ellis on 4/3/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//

import UIKit
import NotificationCenter


@objc (TodayViewController)
class TodayViewController: UIViewController {

    // View
    let todayView = TodayView()
    
    // Model
    var tableData = [LaunchifyPlaylist]()
    
    // Properties
    
    
    // MARK: View Controller Lifecycle
    override func loadView() {
        self.view = todayView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure TableView
        todayView.playlistTableView.dataSource = self
        todayView.playlistTableView.delegate = self
    
        // Update TableView
        updateTableData()
    }
    
    // MARK: Helper Methods
    func updateTableData() {
        tableData = LaunchifyPlaylistsManager.getPinnedPlaylists()
        todayView.playlistTableView.reloadData()
        updatePreferredContentSize()
    }

    func updatePreferredContentSize() {
        preferredContentSize = todayView.playlistTableView.contentSize
    }
}


// MARK: - UITableView(DataSource/Delegate)
extension TodayViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: Data Source
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = tableData[indexPath.row].playlistTitle
        cell.textLabel?.textColor = .whiteColor()
        return cell
    }
    
    // MARK: Delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let spotifyURI = NSURL(string: tableData[indexPath.row].uri)!
        extensionContext?.openURL(spotifyURI, completionHandler: nil)
    }
}

// MARK: - NCWidgetProviding
extension TodayViewController: NCWidgetProviding {
    // TODO: Determine if this is going to be necessary
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        updateTableData()
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.NewData)
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        var margins = defaultMarginInsets
        margins.bottom = 10
        return margins
    }

    
}





