//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Adam Zarn on 7/19/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomButton: UIButton!
    @IBOutlet weak var myMapView: MKMapView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var myView: UIView!
    
    var lat: Double?
    var long: Double?
    
    let invalidAddressAlert:UIAlertController = UIAlertController(title: "Invalid Address", message: "Please enter a valid address.",preferredStyle: UIAlertControllerStyle.Alert)
    let invalidURLAlert:UIAlertController = UIAlertController(title: "Invalid URL", message: "You have entered an invalid URL, do you wish to continue?",preferredStyle: UIAlertControllerStyle.Alert)
    
    func postLocation() {
        if CurrentUser.objectID == "" {
            ParseClient.sharedInstance().postLocation("POST",location:self.locationTextField.text!,link:self.linkTextField.text!,lat:String(self.lat!),long:String(self.long!))
        } else {
            ParseClient.sharedInstance().postLocation("PUT",location:self.locationTextField.text!,link:self.linkTextField.text!,lat:String(self.lat!),long:String(self.long!))
        }
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    @IBAction func bottomButtonPressed(sender: AnyObject) {
        if bottomButton.titleLabel!.text == "Find on the Map" {
            self.geocode(locationTextField.text!)
        } else {
            isSuccess(URLVerified(linkTextField.text!), success: { () -> Void in
                self.postLocation()
                }, error: { () -> Void in
                self.presentViewController(self.invalidURLAlert, animated: true, completion: nil)
            })
        }
    }
    
    func moveToLinkEntry() {
        myView.hidden = true
        myMapView.hidden = false
        locationTextField.enabled = false
        locationTextField.hidden = true
        linkTextField.hidden = false
        topLabel.hidden = true
        bottomButton.setTitle("Submit", forState: .Normal)
        bottomButton.backgroundColor = UIColor.whiteColor()
        bottomButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        bottomButton.layer.borderWidth = 1
        bottomButton.layer.borderColor = UIColor.blackColor().CGColor
        bottomButton.enabled = false
    }
    
    func isSuccess(val:Bool, success: () -> Void, error: () -> Void) {
        if val {
            success()
        } else {
            error()
        }
    }
    
    func URLVerified(urlString: String?) -> Bool {
        if let url = NSURL(string: urlString!) {
            if UIApplication.sharedApplication().canOpenURL(url) {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    func setUpMapView() {

        var annotations = [MKPointAnnotation]()
        let coordinate = CLLocationCoordinate2D(latitude: self.lat!, longitude: self.long!)
        
        myMapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = locationTextField.text!
        annotation.subtitle = ""
        
        annotations.append(annotation)

        self.myMapView.addAnnotations(annotations)
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationTextField.delegate = self
        self.linkTextField.delegate = self
        locationTextField.text = "Enter Your Location Here"
        linkTextField.text = "Enter a Link to Share Here"
        locationTextField.autocorrectionType = .No
        linkTextField.autocorrectionType = .No
        myMapView.hidden = true
        linkTextField.hidden = true
        bottomButton.setTitle("Find on the Map", forState: .Normal)
        invalidAddressAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        
        invalidURLAlert.addAction(UIAlertAction(title:"Continue",
                                                style: UIAlertActionStyle.Default,
                                                handler: {(alert: UIAlertAction!) in
                                                    self.postLocation()}))
        
        invalidURLAlert.addAction(UIAlertAction(title:"Cancel",style: UIAlertActionStyle.Default, handler: nil))
        
        topLabel.font = UIFont(name: "Roboto-Regular", size:34)
        locationTextField.font = UIFont(name: "Roboto-Regular", size:17)
        linkTextField.font = UIFont(name: "Roboto-Regular", size:17)
        bottomButton.titleLabel!.font = UIFont(name: "Roboto-Regular", size:17)
        bottomButton.enabled = false
        bottomButton.layer.cornerRadius = 5
        
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == linkTextField {
            let protectedRange = NSMakeRange(0, 12)
            let intersection = NSIntersectionRange(protectedRange, range)
            if intersection.length > 0 {
                return false
            }
            return true
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.becomeFirstResponder()
        if textField.text == "Enter Your Location Here" {
            textField.text = ""
            bottomButton.enabled = true
        }
        if textField.text == "Enter a Link to Share Here" {
            let attributedString = NSMutableAttributedString(string: "https://www.")
            attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blueColor(), range: NSMakeRange(0,12))
            linkTextField.attributedText = attributedString
            bottomButton.enabled = true
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func geocode(address: String) {
        CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
            if error != nil {
                self.presentViewController(self.invalidAddressAlert, animated: true, completion: nil)
                return
            }
            if placemarks?.count > 0 {
                let placemark = placemarks?[0]
                let location = placemark?.location
                let coordinate = location?.coordinate
                self.lat = coordinate?.latitude
                self.long = coordinate?.longitude
                self.setUpMapView()
                self.moveToLinkEntry()
                if placemark?.areasOfInterest?.count > 0 {
                } else {
                }
            }
        })
    }


}

