//
//  StudentInformationDelegate.swift
//  On the Map
//
//  Created by X.I. Losada on 08/11/15.
//  Copyright © 2015 XiLosada. All rights reserved.
//

import Foundation
import MapKit

protocol StudentInformationDelegate {
    func onLocationSubmitted(coord:CLLocationCoordinate2D)->Void
    func onLocationDeleted(studentInfo:StudentInformation)->Void
}