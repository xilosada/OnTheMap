//
//  ParseApiClient.swift
//  On the Map
//
//  Created by X.I. Losada on 25/10/15.
//  Copyright © 2015 XiLosada. All rights reserved.
//

import Foundation


/**
    SPEC:
    The networking and JSON parsing code is located in a dedicated API client class (and not, for example, inside a view controller). 
    The class uses closures for completion and error handling.
*/
class ParseApiClient: ApiClient{
    
    let _location_limit = 100
    
    //link al singleton
    private static let _instance = ParseApiClient()
    let session: NSURLSession!

    private override init(){
        session = NSURLSession.sharedSession()
    }
    
    static func getSharedInstance()-> ParseApiClient{
        return _instance
    }
    
    /**
        SPEC:
        Downloads the 100 most recent locations posted by students
    */
    func getStudentLocations(completionHandler:(results:[StudentInformation]?,error:NSError?)->Void){
        /**
         SPEC: The app downloads the 100 most recent locations posted by students.
         */
        var paramDict = [String:AnyObject]()
        paramDict[QueryParamsKeys._limit] = _location_limit
        paramDict[QueryParamsKeys._order] = "-"+JsonResponseKeys._updatedAt
        let endpoint = Constants._baseUrl + Methods._studentLocations + escapedParameters(paramDict)
        executeDataRequest(HTTPMethods.GET,endpoint: endpoint, completionHandler:completionHandler)
    }
    
    func getStudentLocationsSql(uniqueId:String, completionHandler:(results:[StudentInformation]?,error:NSError?)->Void){
        let escapedParams = "?\(QueryParamsKeys._where)=%7B%22\(JsonResponseKeys._uniqueKey)%22%3A%22\(uniqueId)%22%7D"
        let endpoint = Constants._baseUrl + Methods._studentLocations + escapedParams
        executeDataRequest(HTTPMethods.GET,endpoint: endpoint, completionHandler:completionHandler)
    }
    
    func postLocation(userId:String,firstname:String,lastName:String,mapString: String,
        mediaURL:String,latitude:Double,longitude:Double,handler:(flag:Bool,error:NSError?)->Void){
        let bodyDict = generateBodyDict(userId,firstname: firstname,lastName: lastName,mapString: mapString,
            mediaURL: mediaURL,latitude: latitude,longitude: longitude)
        let endpoint = Constants._baseUrl + Methods._studentLocations
        executeDataRequest(HTTPMethods.POST,endpoint: endpoint, body: bodyDict, handler:handler)
    }
    
    func updateLocation(objectId:String, userId:String,firstname:String,lastName:String,mapString: String,
        mediaURL:String,latitude:Double,longitude:Double,handler:(flag:Bool,error:NSError?)->Void){
        let bodyDict = generateBodyDict(userId,firstname: firstname,lastName: lastName,mapString: mapString,
            mediaURL: mediaURL,latitude: latitude,longitude: longitude)
        let endpoint = Constants._baseUrl + Methods._studentLocations + "/" + objectId
        executeDataRequest(HTTPMethods.PUT,endpoint: endpoint, body: bodyDict, handler:handler)
    }
    
    /**
        SPEC:
        The networking code uses Swift's built-in NSURLSession library, not a third-party framework.
    */
    func executeDataRequest(httpMethod: String, endpoint:String,body:[String:AnyObject]? = nil,
        completionHandler:(results:[StudentInformation]?,error:NSError?)->Void){
        let task = session.dataTaskWithRequest(generateNetworkRequest(httpMethod, endpoint: endpoint, body: body)){ data, response, error in
            if error != nil {
                completionHandler(results:nil,error:error)
                return
            }
            else{
                self.parseJSONWithCompletionHandler(data!,completionHandler: {
                    (jsonResult,error) in
                    if error != nil{
                        completionHandler(results: nil,error: error)
                        return
                    }else{
                        /**
                        SPEC: The JSON parsing code related to student data is located in a dedicated API client class. The class uses closures for completion and error handling
                        */
                        if let results = jsonResult.valueForKey(JsonResponseKeys._results) as? [[String : AnyObject]] {
                            let locations = StudentInformation.studentInfoArrayFromResults(results)
                            completionHandler(results: locations, error: nil)
                        } else {
                            completionHandler(results: nil, error: NSError(domain: "OTM error parsing", code: ErrorCodes._parsingError, userInfo: [NSLocalizedDescriptionKey: "Could not parse student locations"]))
                        }
                    }
                })
            }
        }
        task.resume()
    }
    
    func executeDataRequest(httpMethod: String, endpoint:String,body:[String:AnyObject]? = nil,
        handler:(flag:Bool,error:NSError?)->Void){
        let task = session.dataTaskWithRequest(generateNetworkRequest(httpMethod, endpoint: endpoint, body: body)){ data, response, error in
            if error != nil {
                handler(flag:false,error:error)
                return
            }
            else{
                self.parseJSONWithCompletionHandler(data!,completionHandler: {
                    (jsonResult,error) in
                    if let error = error { // Handle error…
                        handler(flag: false, error:error)
                    }else{
                        handler(flag: true, error:nil)
                    }
                })
            }
        }
        task.resume()
    }
    
    func generateBodyDict(userId:String,firstname:String,lastName:String,mapString: String,mediaURL:String,latitude:Double,longitude:Double)->[String:AnyObject]{
        var bodyDict = [String:AnyObject]()
        bodyDict[JsonResponseKeys._uniqueKey] = userId
        bodyDict[JsonResponseKeys._firstName] = firstname
        bodyDict[JsonResponseKeys._lastName] = lastName
        bodyDict[JsonResponseKeys._mapString] = mapString
        bodyDict[JsonResponseKeys._mediaURL] = mediaURL
        bodyDict[JsonResponseKeys._latitude] = latitude
        bodyDict[JsonResponseKeys._longitude] = longitude
        return bodyDict
    }
    
    func generateNetworkRequest(httpMethod: String, endpoint:String,body:[String:AnyObject]? = nil)->NSURLRequest{
        let request = NSMutableURLRequest(URL: NSURL(string: endpoint)!)
        request.addValue(Constants._appId, forHTTPHeaderField: HeaderKeys._appIdHeader)
        request.addValue(Constants._apiKey, forHTTPHeaderField: HeaderKeys._apiKeyHeader)
        request.HTTPMethod = httpMethod
        if let body = body{
            request.addValue(Constants._contentTypeJson, forHTTPHeaderField: HeaderKeys._contentType)
            request.HTTPBody = serializedBody(body)
        }
        return request
    }
 }
