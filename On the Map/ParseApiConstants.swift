//
//  ParseApiJsonResponseKeys.swift
//  On the Map
//
//  Created by X.I. Losada on 25/10/15.
//  Copyright © 2015 XiLosada. All rights reserved.
//

import Foundation

extension ParseApiClient{
    
    // MARK: - Methods
    struct Constants{
        static let _baseUrl = "https://api.parse.com/1/classes/"
        static let _appId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let _apiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let _contentTypeJson = "application/json"
    }
    
    // MARK: - Methods
    struct Methods {
        
        // MARK: Account
        static let _studentLocations = "StudentLocation"
    }
    
    struct Errors {
        static let _networkError = NSError(domain: "No connection with host", code: ErrorCodes._noNetworkError, userInfo: nil)
        static let _notValidCredentialsError = NSError(domain: "Invalid Credentials", code: ErrorCodes._credentialsError, userInfo: nil)
    }
    
    
    struct ErrorCodes {
        static let _noNetworkError = 1
        static let _credentialsError = 2
        static let _parsingError = 3
    }
    
    struct HeaderKeys{
        static let _appIdHeader = "X-Parse-Application-Id"
        static let _apiKeyHeader = "X-Parse-REST-API-Key"
        static let _contentType = "Content-Type"

    }
    
    struct QueryParamsKeys{
        static let _limit = "limit"
        static let _order = "order"
        static let _where = "where"
    }

    struct JsonResponseKeys{
        static let _objectId = "objectId"
        static let _uniqueKey = "uniqueKey"
        static let _firstName = "firstName"
        static let _lastName = "lastName"
        static let _mapString = "mapString"
        static let _mediaURL = "mediaURL"
        static let _latitude = "latitude"
        static let _longitude = "longitude"
        static let _createdAt = "createdAt"
        static let _updatedAt = "updatedAt"
        static let _results = "results"
    }
}

