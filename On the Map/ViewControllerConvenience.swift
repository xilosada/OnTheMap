//
//  ViewControllerConvenience.swift
//  On the Map
//
//  Created by X.I. Losada on 09/11/15.
//  Copyright © 2015 XiLosada. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController{
    

    /**
        SPEC: 
        The app uses an Alert View Controller to notify the user if the login connection fails. 
     */
    func showError(message:String){
        dispatch_async(dispatch_get_main_queue(),{
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    /**
        SPEC:
        An activity indicator is displayed during geocoding, and returns to normal state on completion.
    */
    func showActivityIndicator()->UIActivityIndicatorView{
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityView.center = self.view.center
        activityView.startAnimating()
        view.addSubview(activityView)
        return activityView
    }
    
    func releaseActivityIndicator(activityIndicatorView:UIActivityIndicatorView){
        dispatch_async(dispatch_get_main_queue(),{
            activityIndicatorView.stopAnimating()
            activityIndicatorView.removeFromSuperview()
        })
    }
    
    func dismissViewFromMainQueue(){
        dispatch_async(dispatch_get_main_queue(),{
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
}