//
//  CinemaMapViewController.swift
//  CinemaAssistant
//
//  Created by Cheuk Hei Lo on 30/11/2019.
//  Copyright © 2019 Cheuk Hei Lo. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class CinemaMapViewController: UIViewController {
    
    var address: String = ""
    var cinemaName: String = ""
    var lat: CLLocationDegrees = 0.0
    var lon: CLLocationDegrees = 0.0
    
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(address)
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
            else {
                // handle no location found
                print("no location is found")
                return
            }

            // Use your location
            self.lat = location.coordinate.latitude
            self.lon = location.coordinate.longitude
            
            let initialLocation = CLLocation(latitude: self.lat, longitude: self.lon)
                
                let regionRadius: CLLocationDistance = 300
                
                let coordinateRegion = MKCoordinateRegion(
                        center: initialLocation.coordinate,
                        latitudinalMeters: regionRadius * 2.0,
                        longitudinalMeters: regionRadius * 2.0)
                
            self.map.setRegion(coordinateRegion, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: self.lat, longitude: self.lon)
            annotation.title = self.cinemaName
            self.map.addAnnotation(annotation)
            
            
        }
        
        
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

