//
//  AddPinViewController.swift
//  On the Map
//
//  Created by X.I. Losada on 04/11/15.
//  Copyright © 2015 XiLosada. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class AddPinViewController: UIViewController, UITextFieldDelegate {
    
    var geoCoder: CLGeocoder!
    var lastPositionId: String?
    var delegate: SubmitLocationDelegate?
    var placemark: CLPlacemark?
    var searchMode: Bool = true
    var activityIndicatorView: UIActivityIndicatorView?
    
    let _addressTextInputLabel = "Where are you studying today?"
    let _linkTextInputLabel = "Share something!"
    let _addressTextPlaceholder = "Enter an address"
    let _linkTextPlaceholder = "Enter a link"
    let _searchButtonLabel = "Search"
    let _submitButtonLabel = "Submit"
    
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var inputTextView: UITextField!
    
    @IBOutlet weak var mapView: MKMapView!
    
    /**
        SPEC:
        The app provides a readily accessible "Submit" button that the user can tap to post the information to the server
    */
    @IBOutlet weak var confirmButton: UIButton!
    
    static func presentController(controller:UIViewController,delegate:SubmitLocationDelegate?=nil,updatePositionId:String?=nil)->AddPinViewController{
        let mStoryBoard: UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
        let addPinViewControler:AddPinViewController = mStoryBoard.instantiateViewControllerWithIdentifier("AddPinViewController") as! AddPinViewController
        addPinViewControler.delegate = delegate
        addPinViewControler.lastPositionId = updatePositionId
        controller.presentViewController(addPinViewControler, animated: true, completion: nil)
        return addPinViewControler
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeToSearchMode()
        inputTextView.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchPressed(confirmButton)
        return true
    }
    
    func changeToSearchMode(){
        configureMode(true)
    }
    
    func changeToSubmitMode(){
        configureMode(false)
        configureMap()
    }
    
    func configureMode(searchMode:Bool){
        self.searchMode = searchMode
        infoLabel.text = searchMode ? _addressTextInputLabel : _linkTextInputLabel
        inputTextView.text = ""
        inputTextView.placeholder = searchMode ? _addressTextPlaceholder : _linkTextPlaceholder
        
        ///http://stackoverflow.com/questions/19973515/
        let labelText = searchMode ? _searchButtonLabel : _submitButtonLabel
        confirmButton.setAttributedTitle(NSAttributedString(string:labelText), forState: .Normal)
        mapView.hidden = searchMode
    }
    
    /**
        SPEC:
        The app shows a placemark on a map via the geocoded response. The app zooms the map into an appropriate region.
    */
    func configureMap(){
        let annotation = MKPointAnnotation()
        if let coordinate = placemark?.location!.coordinate {
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            //http://stackoverflow.com/questions/17266093/
            mapView.setRegion(MKCoordinateRegionMake(coordinate,MKCoordinateSpan(latitudeDelta: 100,longitudeDelta: 100)), animated: true)
        }else{
            showError("Not found a valid position")
            changeToSearchMode()
        }
    }
    
    /**
        SPEC:
        The app provides a readily accessible button that the user can tap to cancel (dismiss) the Information Posting View
    */
    @IBAction func cancelPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    

    @IBAction func searchPressed(sender: AnyObject) {
        if inputTextView.text == ""{
            showError("Please fill the text field")
            return
        }
        disableUIElements()
        if searchMode{
            /**
            SPEC:
                When a "Submit" button is pressed, the app invokes the geocode address string on CLGeocoder with a completion block
                that stores the resulting latitude and longitude.
            */
            if let address = inputTextView.text {
                CLGeocoder().geocodeAddressString(address) { (placemarks, error) -> Void in
                    self.enableUIElements()
                    if let firstPlacemark = placemarks?[0] {
                        self.placemark =  firstPlacemark
                        self.changeToSubmitMode()
                    }
                    else{
                        //SPEC: The app displays an alert if the geocoding fails.
                        self.showError("0 addresses found")
                    }
                }
            } else {
                self.showError("Error geocoding")
            }
        } else{
            let udapi = UdacityApiClient.getSharedInstance()
            let parseapi = ParseApiClient.getSharedInstance()
            let coordinate: CLLocationCoordinate2D = (placemark?.location?.coordinate)!
            if let updateId = lastPositionId {
                parseapi.updateLocation(updateId,userId:udapi.userID!, firstname: udapi.userFirstName!, lastName: udapi.userLastName!, mapString: (placemark?.locality)!, mediaURL: inputTextView.text!, latitude: coordinate.latitude, longitude: coordinate.longitude, handler: pinUploadDidFinish)
            }else{
                parseapi.postLocation(udapi.userID!, firstname: udapi.userFirstName!, lastName: udapi.userLastName!, mapString: (placemark?.locality)!, mediaURL: inputTextView.text!, latitude: coordinate.latitude, longitude: coordinate.longitude,handler: pinUploadDidFinish)
            }
        }
    }

    func enableUIElements(){
        enableUIElements(true)
        releaseActivityIndicator(activityIndicatorView!)
    }
    
    func disableUIElements(){
        enableUIElements(false)
        activityIndicatorView = showActivityIndicator()
    }
    
    /**
        EXCEEDS SPEC:
        The app shows additional indications of activity, such as modifying alpha/transparency of interface elements.
    */
    func enableUIElements(enabled:Bool){
        self.view.alpha = enabled ? 1 : 0.3
        inputTextView.enabled = enabled
        confirmButton.enabled = enabled
    }
    
    func pinUploadDidFinish(flag:Bool,error:NSError?){
        self.enableUIElements()
        if let error = error{
            self.delegate?.onPostError(error)
        }else{
            self.delegate?.onLocationSubmitted((self.placemark?.location?.coordinate)!)
        }
        self.dismissViewFromMainQueue()
    }
}