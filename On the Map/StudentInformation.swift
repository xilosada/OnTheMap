//
//  StudentInformation.swift
//  On the Map
//
//  Created by X.I. Losada on 25/10/15.
//  Copyright © 2015 XiLosada. All rights reserved.
//

import Foundation

/**
SPEC: The app contains a StudentInformation struct with appropriate properties for locations and links
*/
struct StudentInformation{
    
    ///an auto-generated id/key generated by Parse which uniquely identifies a StudentLocation
    var objectId: String?

    ///an extra (optional) key used to uniquely identify a StudentLocation; you should populate this value using your Udacity account (user) id
    var uniqueKey: String
    
    ///the first name of the student which matches their Udacity profile first name
    var firstName: String
    
    /// the last name of the student which matches their Udacity profile last name
    var lastName: String
    
    ///the location string used for geocoding the student location
    var mapString: String
    
    ///the URL provided by the student
    var mediaURL: String
    
    ///the latitude of the student location (ranges from -90 to 90)
    var latitude: Float
    
    ///the longitude of the student location (ranges from -180 to 180)
    var longitude: Float

    ///the date when the student location was created
    var createdAt: String?
    
    ///the date when the student location was last updated
    var updatedAt: String?
    
    /**
     SPEC: The struct has an init() method that accepts a dictionary as an argument
     */
    init(dictionary: [String : AnyObject]){
        objectId = dictionary[ParseApiClient.JsonResponseKeys._objectId] as? String
        uniqueKey = dictionary[ParseApiClient.JsonResponseKeys._uniqueKey] as! String
        firstName = dictionary[ParseApiClient.JsonResponseKeys._firstName] as! String
        lastName = dictionary[ParseApiClient.JsonResponseKeys._lastName] as! String
        mapString = dictionary[ParseApiClient.JsonResponseKeys._mapString] as! String
        mediaURL = dictionary[ParseApiClient.JsonResponseKeys._mediaURL] as! String
        latitude = dictionary[ParseApiClient.JsonResponseKeys._latitude] as! Float
        longitude = dictionary[ParseApiClient.JsonResponseKeys._longitude] as! Float
        createdAt = dictionary[ParseApiClient.JsonResponseKeys._longitude] as? String
        updatedAt = dictionary[ParseApiClient.JsonResponseKeys._longitude] as? String
    }
    
    static func studentInfoArrayFromResults(results: [[String : AnyObject]]) -> [StudentInformation] {
        var locations = [StudentInformation]()
        
        for location in results {
            locations.append(StudentInformation(dictionary: location))
        }
        return locations
    }
    
}