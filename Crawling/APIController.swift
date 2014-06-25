//
//  APIController.swift
//  Crawling
//
//  Created by Andrew Dennis on 6/24/14.
//  Copyright (c) 2014 Andrew Dennis. All rights reserved.
//

import UIKit

protocol APIControllerProtocol {
    func didReceiveAPIResults(results: NSDictionary)
}

class APIController {
    
    var delegate: APIControllerProtocol?

    init(delegate: APIControllerProtocol?) {
        self.delegate = delegate
    }
    
    
    func searchItunesFor(searchTerm: String) {
        var itunesSearchTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        var escapedSearchTerm = itunesSearchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        
        var urlPath = "https://itunes.apple.com/search?term=\(escapedSearchTerm)&media=software"
        var url: NSURL = NSURL(string: urlPath)
        var request: NSURLRequest = NSURLRequest(URL: url)
        println("Search iTunes API at URL \(url)")
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if error? {
                println("ERROR: \(error.localizedDescription)")
            }
            else {
                var error: NSError?
                let jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
                
                if error? {
                    println("HTTP Error: \(error?.localizedDescription)")
                }
                else {
                    println("Results received")
                    self.delegate?.didReceiveAPIResults(jsonResult)
                }
            }
        })
    }
}
