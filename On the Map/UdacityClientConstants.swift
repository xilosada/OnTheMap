//
//  UdacityClientConstants.swift
//  On the Map
//
//  Created by X.I. Losada on 05/11/15.
//  Copyright © 2015 XiLosada. All rights reserved.
//

import Foundation

extension UdacityApiClient{
    
    // MARK: - Methods
    struct Constants{
        static let _baseUrl = "https://www.udacity.com/api/"
        static let _contentTypeJson = "application/json"
    }
    
    // MARK: - Methods
    struct Methods {
    
        // MARK: Account
        static let _session = "session"
        static let _users = "users"
    }
    
    struct Errors {
        static let _networkError = NSError(domain: "No connection with host", code: ErrorCodes._noNetworkError, userInfo: nil)
        static let _notValidCredentialsError = NSError(domain: "Invalid Credentials", code: ErrorCodes._credentialsError, userInfo: nil)
    }
    
    struct HeaderKeys{
        static let _appIdHeader = "X-Parse-Application-Id"
        static let _contentType = "Content-Type"
        static let _accept = "Accept"
        static let _xsrf_token = "X-XSRF-TOKEN"
    }
    
    struct CookieKeys{
        static let _xsrf_token = "XSRF-TOKEN"
    }

    struct ErrorCodes {
        static let _noNetworkError = 1
        static let _credentialsError = 2
        static let _parsingError = 3
    }

    struct JsonBodyKeys{
        static let _facebook = "facebook_mobile"
        static let _access_token = "access_token"
        static let _udacity = "udacity"
        static let _username = "username"
        static let _password = "password"
    }
    
    struct JsonResponseKeys{
        static let _key = "key"
        static let _account = "account"
        static let _user = "user"
        static let _firstName = "first_name"
        static let _lastName = "last_name"
        static let _status_message = "status_message"
    }
}