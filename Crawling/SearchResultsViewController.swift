//
//  SearchResultsViewController.swift
//  Crawling
//
//  Created by Andrew Dennis on 6/24/14.
//  Copyright (c) 2014 Andrew Dennis. All rights reserved.
//

import UIKit

class SearchResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, APIControllerProtocol {
    
    let kCellIdentifier: String = "SearchResultCell"
    
    @IBOutlet var appsTableView: UITableView
    var tableData: NSArray = NSArray()
    var api: APIController = APIController()
    var imageCache = NSMutableDictionary()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.api.delegate = self
        api.searchItunesFor("Angry Birds")
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: kCellIdentifier)
        }
        
        var rowData: NSDictionary = self.tableData[indexPath.row] as NSDictionary
        
        let cellText: String? = rowData["trackName"] as? String
        cell.text = cellText
        cell.image = UIImage(named: "Blank52")
        
        var formattedPrice: NSString = rowData["formattedPrice"] as NSString
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var urlString: NSString = rowData["artworkUrl60"] as NSString
            var image: UIImage? = self.imageCache.valueForKey(urlString) as? UIImage
            
            if( !image? ) {
                var imgURL: NSURL = NSURL(string: urlString)
                var request: NSURLRequest = NSURLRequest(URL: imgURL)
                var urlConnection: NSURLConnection = NSURLConnection(request: request, delegate: self)
                
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                    if !error? {
                        image = UIImage(data: data)
                        self.imageCache.setValue(image, forKey: urlString)
                        cell.image = image
                    }
                    else {
                        println("Error: \(error.localizedDescription)")
                    }
                })
            }
            else {
                cell.image = image
            }

        })
        
        cell.detailTextLabel.text = formattedPrice
            
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        var rowData: NSDictionary = self.tableData[indexPath.row] as NSDictionary
        var name: String = rowData["trackName"] as String
        var formattedPrice: String = rowData["formattedPrice"] as String
        
        var alert: UIAlertView = UIAlertView()
        alert.title = name
        alert.message = formattedPrice
        alert.addButtonWithTitle("OK")
        alert.show()
    }
    
    func didReceiveAPIResults(results: NSDictionary) {
        if results.count > 0 {
            self.tableData = results["results"] as NSArray
            self.appsTableView.reloadData()
        }
    }
    
}