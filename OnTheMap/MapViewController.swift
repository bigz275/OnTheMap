//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Adam Zarn on 7/20/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var myMapView: MKMapView!
    
    let alreadyPostedAlert:UIAlertController = UIAlertController(title: "Location Already Exists", message: "A location for you already exists, what would you like to do?",preferredStyle: UIAlertControllerStyle.Alert)
    let unableToLogoutAlert:UIAlertController = UIAlertController(title: "Unable to Logout", message: "You are unable to logout at this time.",preferredStyle: UIAlertControllerStyle.Alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getLocationData()
        
        alreadyPostedAlert.addAction(UIAlertAction(title:"Overwrite", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextController = storyboard.instantiateViewControllerWithIdentifier("InformationPostingViewController") as! InformationPostingViewController
            self.presentViewController(nextController, animated: true, completion: nil)
        }))
        unableToLogoutAlert.addAction(UIAlertAction(title:"OK",style: UIAlertActionStyle.Default, handler: nil))
        alreadyPostedAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        
    }
    
    func getLocationData() {
        ParseClient.sharedInstance().getLocationData { (result, error) -> () in
            if let result = result {
                self.setUpMapView()
            } else {
                print(error)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.getLocationData()
    }
    
    @IBAction func refreshData(sender: AnyObject) {
        self.getLocationData()
    }
    
    @IBAction func startPost(sender: AnyObject) {
        ParseClient.sharedInstance().doesStudentLocationExist { (objectID, error) -> () in
            if let objectID = objectID {
                if objectID == "" {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let nextController = storyboard.instantiateViewControllerWithIdentifier("InformationPostingViewController") as! InformationPostingViewController
                    self.presentViewController(nextController, animated: true, completion: nil)
                } else {
                    CurrentUser.objectID = objectID
                    self.presentViewController(self.alreadyPostedAlert, animated: true, completion: nil)
                }
            } else {
                print(error)
            }
        }
    }
    
    func setUpMapView() {
    
        let allAnnotations = self.myMapView.annotations
        self.myMapView.removeAnnotations(allAnnotations)
        
        let locations = StudentInformation.studentInformationArray
    
        var annotations = [MKPointAnnotation]()
    
        for studentInfo in locations {
            let lat = CLLocationDegrees(studentInfo.latitude as! Double)
            let long = CLLocationDegrees(studentInfo.longitude as! Double)
    
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
    
            let first = studentInfo.firstName as! String
            let last = studentInfo.lastName as! String
            let mediaURL = studentInfo.mediaURL as! String
    
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
    
            annotations.append(annotation)
        }
        self.myMapView.addAnnotations(annotations)
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        return pinView

    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }
    
    @IBAction func logoutPressed() {
        UdacityClient.sharedInstance().logout { (result, error) -> () in
            if let result = result {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let nextController = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
                self.presentViewController(nextController, animated: true, completion: nil)
            } else {
                print(error)
                self.presentViewController(self.unableToLogoutAlert, animated: true, completion: nil)
            }
        }
    }
    
}

