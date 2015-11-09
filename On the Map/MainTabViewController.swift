//
//  MainTabViewController.swift
//  On the Map
//
//  Created by X.I. Losada on 04/11/15.
//  Copyright © 2015 XiLosada. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit
import MapKit

class MainTabViewController: UITabBarController, SubmitLocationDelegate{
    
    var childControllers: [UIViewController]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        childControllers = self.viewControllers
        reloadLocations()
    }

    /**
        SPEC:
        The Student Locations Tabbed View has a logout button in the upper left corner of the navigation bar. 
        The logout button causes the Student Locations Tabbed View to dismiss, and logs out of the current session.
    */
    @IBAction func logoutPressed(sender: AnyObject) {
        let udapi = UdacityApiClient.getSharedInstance()
        if(udapi.loggedWithUdacity){
            udapi.logout({result, error in
            })
        }else{
            ///EXCEEDS SPEC:  If applicable, the logout button logs out of the current Facebook session
            FBSDKLoginManager().logOut()
        }
        udapi.userID = nil
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
        SPEC:
        The Student Locations Tabbed View has a pin button in the upper right corner of the navigation bar. 
        The button modally presents the Information Posting View so that users can post their own information to the server
     */
    @IBAction func addPinPressed(sender: AnyObject) {
        checkPreviousPins(
            {studentInformation in
                if let studentInformation = studentInformation{
                    self.showConfirmationDialog("A pin already exists. Do you want to overwrite it?", onAccepted: { alert in
                    AddPinViewController.presentController(self, delegate: self, updatePositionId: studentInformation.objectId)
                    })
                }else{
                    AddPinViewController.presentController(self, delegate: self)
                }

            },onError: {error in
                self.showError("Error getting locations")
        })
    }
    
    func onLocationSubmitted(coord: CLLocationCoordinate2D) {
        dispatch_async(dispatch_get_main_queue(),{
            self.reloadLocations()
            (self.childControllers![0] as! MapViewController).centerMap(coord)
        })
    }
    
    /**
        SPEC:
        The user sees an alert if the post fails.
    */
    func onPostError(error:NSError){
        showError(error.localizedDescription)
    }
    
    func reloadLocations(){
        let parseApi = ParseApiClient.getSharedInstance()
        parseApi.getStudentLocations { (results, error) -> Void in
            if let error = error{
                self.showError(error.localizedDescription)
            }else{
                StudentCache.getSharedInstance().setNewDataSet(results!)
                self.reloadMap()
                self.reloadTable()
            }
        }
    }
    
    func reloadMap(){
        (childControllers![0] as! MapViewController).updateMapPins()
    }
    
    func reloadTable(){
        (childControllers![1] as! TableViewController).tableView.reloadData()
    }
    
    func showConfirmationDialog(message:String,onAccepted:(UIAlertAction)->Void){
        dispatch_async(dispatch_get_main_queue(),{
            let alert = UIAlertController(title: "Confirmation", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: onAccepted))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    func checkPreviousPins(onSuccess:(StudentInformation?)->Void,onError:(NSError)->Void){
        ParseApiClient.getSharedInstance().getStudentLocationsSql(UdacityApiClient.getSharedInstance().userID!, completionHandler:{
            results,error in
            if let error = error {
                onError(error)
            }else{
                if results?.count>0{
                    onSuccess(results![0])
                }else{
                    onSuccess(nil)
                }
            }
        })
    }
}