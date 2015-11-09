//
//  ApiClient.swift
//  On the Map
//
//  Created by X.I. Losada on 09/11/15.
//  Copyright © 2015 XiLosada. All rights reserved.
//

import Foundation

class ApiClient: NSObject{
    
    struct HTTPMethods{
        static let GET = "GET"
        static let POST = "POST"
        static let PUT = "PUT"
        static let DELETE = "DELETE"
    }
    
    /** 
        SPEC:
        The JSON parsing code uses Swift's built-in NSJSONSerialization library, not a third-party framework.
    */
    func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        var parsingError: NSError? = nil
        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    /* Helper function: Given a dictionary of body parameters, encode to UTF8 */
    func serializedBody(body: [String : AnyObject]) -> NSData {
        return serializeBodyRecursive(body).dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    func serializeBodyRecursive(body: [String : AnyObject]) -> String {
        var urlVars = [String]()
        for (key, value) in body {
            var finalValue : AnyObject
            if value is String{
                finalValue = "\"\(value)\""
            }else if value is [String:AnyObject]{
                finalValue = serializeBodyRecursive(value as! [String : AnyObject])
            }else{
                finalValue = value
            }
            urlVars += ["\"\(key)\":\(finalValue)"]
        }
        return "{\(urlVars.joinWithSeparator(","))}"
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
}
