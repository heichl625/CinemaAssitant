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
import Alamofire
import GoogleMaps

class CinemaMapViewController: UIViewController {
    
    var address: String = ""
    var cinemaName: String = ""
    var lat = 0.0
    var lon = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(lat, lon)
        
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 17.0)
        let mapView = GMSMapView.map(withFrame: self.view.bounds, camera: camera)
        mapView.animate(to: camera)
        self.view.addSubview(mapView)
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        marker.title = cinemaName
        marker.snippet = address
        marker.map = mapView
        
        mapView.selectedMarker = marker
//        print(address)
//        let geoCoder = CLGeocoder()
//        geoCoder.geocodeAddressString(address) { (placemarks, error) in
//            guard
//                let placemarks = placemarks,
//                let location = placemarks.first?.location
//            else {
//                // handle no location found
//                print("no location is found")
//                return
//            }
//
//            // Use your location
//            self.lat = location.coordinate.latitude
//            self.lon = location.coordinate.longitude
//
//            let initialLocation = CLLocation(latitude: self.lat, longitude: self.lon)
//
//                let regionRadius: CLLocationDistance = 300
//
//                let coordinateRegion = MKCoordinateRegion(
//                        center: initialLocation.coordinate,
//                        latitudinalMeters: regionRadius * 2.0,
//                        longitudinalMeters: regionRadius * 2.0)
//
//            self.map.setRegion(coordinateRegion, animated: true)
//
//            let annotation = MKPointAnnotation()
//            annotation.coordinate = CLLocationCoordinate2D(latitude: self.lat, longitude: self.lon)
//            annotation.title = self.cinemaName
//            self.map.addAnnotation(annotation)
            
            
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

