//
//  ListViewController.swift
//  On The Map
//
//  Created by Adam Cmiel on 11/1/15.
//  Copyright © 2015 Adam Cmiel. All rights reserved.
//

import UIKit

let CELL_IDENTIFIER = "cell"

class ListViewController: TabViewController, UITableViewDelegate, UITableViewDataSource, Refreshing {
    @IBOutlet weak var tableView: UITableView?
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store.data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER, forIndexPath: indexPath)
        let data = store.data[indexPath.row]
        cell.textLabel!.text = data.name
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let data = store.data[indexPath.row]
        let urlPath = data.mediaURL
        
        if let url = NSURL(string: urlPath) {
            let tbController = tabBarController as! TabBarController
            tbController.presentSafariViewController(url)
        }
    }
    
    // MARK: - Refreshing
    
    func refresh(data: [StudentInformationAnnotation]) {
        tableView?.reloadData()
        print("got student locations")
    }
}
