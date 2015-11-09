//
//  UdacityApiClient.swift
//  On the Map
//
//  Created by X.I. Losada on 05/11/15.
//  Copyright © 2015 XiLosada. All rights reserved.
//

import Foundation

/**
    SPEC: The networking code related to login is located in a dedicated API client class. The class uses closures for completion and error handling
*/
class UdacityApiClient: ApiClient {
        
    /* Shared session */
    var session: NSURLSession
    
    /* Authentication state */
    var userID : String? = nil
    var userFirstName : String? = nil
    var userLastName : String? = nil
    var loggedWithUdacity : Bool = false
    
    //link to the singleton
    private static let _instance = UdacityApiClient()
    
    private override init(){
        session = NSURLSession.sharedSession()
    }
    
    static func getSharedInstance()-> UdacityApiClient{
        return _instance
    }
    
    func login(email:String,password:String, completionHandler: (userId: String?, error: NSError?)->Void){
        
        var credentialsDict = [String:AnyObject]()
        credentialsDict[JsonBodyKeys._username] = email
        credentialsDict[JsonBodyKeys._password] = password
        
        var bodyDict = [String:AnyObject]()
        bodyDict[JsonBodyKeys._udacity] = credentialsDict
        
        let request = generatePostRequest(Methods._session,body: bodyDict)
        executeSessionTask(request,completionHandler: { jsonResult ,error
            in
            if let error = error {
                completionHandler(userId: nil, error: error)
            }else{
                self.parseUserId(jsonResult, completionHandler: completionHandler)
            }
        })
    }
    
    func loginWithFacebook(token:String,completionHandler: (userId: String?, error: NSError?)-> Void){
        
        var bodyDict = [String:AnyObject]()
        bodyDict[JsonBodyKeys._facebook] = [JsonBodyKeys._access_token:token]
        
        let request = generatePostRequest(Methods._session,body: bodyDict)
        executeSessionTask(request,completionHandler: { jsonResult ,error
            in
            if let error = error {
                completionHandler(userId: nil, error: error)
            }else{
                self.parseUserId(jsonResult, completionHandler: completionHandler)
            }
        })
    }
    
    func logout(completionHandler: (flag: Bool, error: NSError?)->Void){
        let request = generateDeleteRequest(Methods._session)
        executeSessionTask(request,completionHandler: { jsonResult ,error
            in
            if error != nil {
                self.loggedWithUdacity = false
                completionHandler(flag : false, error: error)
            }else{
                completionHandler(flag : true, error: nil)
            }
        })
    }
    
    func getUserDataById(id:String, completionHandler: (flag:Bool, error: NSError?)-> Void){
        let request = generateRequest("\(Methods._users)/\(id)")
        executeSessionTask(request,completionHandler: { jsonResult ,error in
            if let error = error{
                completionHandler(flag: false,error: error)
            }
            else if let studentInfo = jsonResult.valueForKey(JsonResponseKeys._user){
                self.userFirstName = studentInfo[JsonResponseKeys._firstName] as? String
                self.userLastName = studentInfo[JsonResponseKeys._lastName] as? String
                completionHandler(flag: true,error: nil)
            }
            else{
                completionHandler(flag: false,error: NSError(domain: "OTM Parsing Error", code: 2, userInfo: nil))
            }
        })
    }
    
    private func generateRequest(method:String) -> NSMutableURLRequest{
        return NSMutableURLRequest(URL: NSURL(string: Constants._baseUrl+method)!)
    }

    private func generatePostRequest(method:String,body:[String:AnyObject]) -> NSMutableURLRequest{
        let request = generateRequest(method)
        request.HTTPMethod = HTTPMethods.POST
        request.addValue(Constants._contentTypeJson, forHTTPHeaderField: HeaderKeys._accept)
        request.addValue(Constants._contentTypeJson, forHTTPHeaderField: HeaderKeys._contentType)
        request.HTTPBody = serializedBody(body)
        return request
    }
  
    private func generateDeleteRequest(method:String) -> NSMutableURLRequest{
        let request = generateRequest(method)
        request.HTTPMethod = HTTPMethods.DELETE
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as [NSHTTPCookie]! {
            if cookie.name == CookieKeys._xsrf_token { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: HeaderKeys._xsrf_token)
        }
        return request
    }
    
    /**
        SPEC:
        The networking code uses Swift's built-in NSURLSession library, not a third-party framework.
     */
    private func executeSessionTask(request:NSURLRequest, completionHandler: (result: AnyObject!, error: NSError?)-> Void) -> NSURLSessionDataTask {
        let task = session.dataTaskWithRequest(request) { data, response, networkError in
            if let error = networkError { // Handle error…
                let newError = self.errorForData(data, response: response, error: error)
                completionHandler(result: nil,error: newError)
            }else{
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                self.parseJSONWithCompletionHandler(newData,completionHandler: completionHandler)
            }
        }
        task.resume()
        return task
    }
    
    /**
        SPEC:
        The JSON parsing code related to student data is located in a dedicated API client class. The class uses closures for completion and error handling.
     */
    private func parseUserId(data: AnyObject, completionHandler: (userId: String!, error: NSError?)-> Void){
        if let results = data.valueForKey(JsonResponseKeys._account) as? [String : AnyObject] {
            let id = results[JsonResponseKeys._key] as! String
            self.getUserDataById(id, completionHandler:{ flag,error in
                if flag{
                    self.userID = id
                    completionHandler(userId: id ,error:nil)
                }else{
                    completionHandler(userId: nil ,error:error)
                }
            })
        }else{
            completionHandler(userId: nil ,error:Errors._notValidCredentialsError)
        }
    }
    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    private func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        if error.domain == NSURLErrorDomain {
            return Errors._networkError
        }
        if let parsedResult = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as? [String : AnyObject] {
            if let errorMessage = parsedResult[JsonResponseKeys._status_message] as? String {
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                return NSError(domain: "OTM Parsing Error", code: ErrorCodes._parsingError, userInfo: userInfo)
            }
        }
        return error
    }
}