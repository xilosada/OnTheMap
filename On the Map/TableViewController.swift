//
//  TableViewController.swift
//  On the Map
//
//  Created by X.I. Losada on 05/11/15.
//  Copyright © 2015 XiLosada. All rights reserved.
//

import Foundation
import UIKit


/**
    SPEC:
    The app displays downloaded data in a tabbed view with a map and a table.
 */
class TableViewController: UITableViewController {
    
    let _font_name_subtitle = "Roboto-Medium"
    let _font_name_title = "Roboto-Regular.ttf"
    
    var delegate: StudentInformationDelegate?
    
    var studentInformations: [StudentInformation]! {
        return StudentCache.getSharedInstance().getData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return studentInformations.count
    }
    
    /**
        SPEC:
        The table has a row for each downloaded record with the student’s name displayed
     */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SLTableViewCell")! as! SLTableViewCell
        let sInfo = studentInformations[indexPath.row]
        
        configureAsTitle(cell.titleTextView!)
        configureAsSubtitle(cell.subtitleTextView!)
        cell.titleTextView.text = "\(sInfo.firstName) \(sInfo.lastName), \(sInfo.mapString)"
        cell.subtitleTextView.text = sInfo.mediaURL
        return cell
    }
    
    /**
        SPEC:
        Tapping a row in the table opens the default device browser to the student's link.
     */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let url = NSURL(string:studentInformations[indexPath.row].mediaURL){
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    /**
     EXCEEDS SPEC:
     The app displays downloaded data in a tabbed view with a map and a table.
     The table is modified to be visually interesting
     */
    func configureAsTitle(uiLabel: UILabel){
        configureText(uiLabel,isTitle:true)
    }
    
    func configureAsSubtitle(uiLabel: UILabel){
        configureText(uiLabel,isTitle:false)
    }
    
    func configureText(uiLabel: UILabel, isTitle: Bool){
        uiLabel.font = UIFont(name: isTitle ? _font_name_title : _font_name_subtitle, size: isTitle ? 17 : 13)
        uiLabel.textColor = isTitle ? UIColor.blackColor() : UIColor.grayColor()
    }
    
    /**
        Delete a StudentInformation from server if logged user is the owner
    */
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete{
            let studentInfo = studentInformations[indexPath.row]
            let userId = UdacityApiClient.getSharedInstance().userID
            
            if studentInfo.uniqueKey == userId{
                ParseApiClient.getSharedInstance().deleteLocation(studentInfo, handler: {flag,error in
                    if flag {
                        //studentInformations.removeAtIndex(indexPath.row)
                        self.showAlert("Operation Success", message: "Pin deleted")
                        self.delegate?.onLocationDeleted(studentInfo)
                    }else{
                        self.showError(flag ? "Eliminado": (error?.localizedDescription)!)
                    }
                })
            }else{
                self.showError("Is not your Pin. Your ID \(userId) != \(studentInfo.uniqueKey)) ")
            }
        }
    }
}
