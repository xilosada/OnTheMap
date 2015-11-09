//
//  StudentCache.swift
//  On the Map
//
//  Created by X.I. Losada on 05/11/15.
//  Copyright © 2015 XiLosada. All rights reserved.
//

import Foundation

class StudentCache : NSObject{
    
    /**
     SPEC:
     The StudentInformation structs are stored as an array (or other suitable data structure) inside a separate model class, not in the view controller
     */
    private var studentInformations = [StudentInformation]()

    //link al singleton
    private static let _instance = StudentCache()
    
    static func getSharedInstance()-> StudentCache{
        return _instance
    }
    
    /**
        SPEC:
        The table is sorted in order of most recent to oldest update.
    */
    func setNewDataSet(data:[StudentInformation]){
        studentInformations = data.sort{ $0.updatedAt > $1.updatedAt}
    }
    
    func getData()->[StudentInformation]{
        return studentInformations
    }
}