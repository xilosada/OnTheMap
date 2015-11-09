//
//  MapViewController.swift
//  On the Map
//
//  Created by X.I. Losada on 04/11/15.
//  Copyright © 2015 XiLosada. All rights reserved.
//

import Foundation
import UIKit
import MapKit

/**
    SPEC:
    The app displays downloaded data in a tabbed view with a map and a table.
 */
class MapViewController : UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var studentInformations: [StudentInformation]! {
        return StudentCache.getSharedInstance().getData()
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    func mapView(mapView: MKMapView,viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?
    {
        let identifier = annotation.title!
        let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        if NSURL(string:annotation.subtitle!!) != nil{
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
        }
        return view
    }
    
    /**
        SPEC:
        Tapping a student’s pin annotation opens the default device browser to the student’s link.
    */
    func mapView(mapView: MKMapView,annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        if let url = NSURL(string:view.annotation!.subtitle!!){
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    /**
        SPEC:
        The map view has a pin for each student in the correct location.
    */
    func updateMapPins(){
        dispatch_async(dispatch_get_main_queue(), {
        self.mapView.removeAnnotations(self.mapView.annotations)
        for studentInfo in self.studentInformations!{
            
            // SPEC: Tapping the pins shows an annotation with the student's name and the link the student posted
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(studentInfo.latitude), CLLocationDegrees(studentInfo.longitude))
            annotation.title = studentInfo.firstName + " " + studentInfo.lastName
            annotation.subtitle = studentInfo.mediaURL
            self.mapView.addAnnotation(annotation)
        }
        })
    }
    
    func centerMap(centerMap:CLLocationCoordinate2D){
        mapView.camera.centerCoordinate = centerMap
    }
}