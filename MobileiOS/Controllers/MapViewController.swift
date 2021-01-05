//
//  MapViewController.swift
//  MobileiOS
//
//  Created by George on 07.12.2020.
//

//import MapKit
//import CoreLocation
//
//class MapViewController: UIViewController, MKMapViewDelegate {
//
//    @IBOutlet weak var mapView: MKMapView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        locationManager.delegate = self
//        mapView.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//    }
//
//    lazy var locationManager: CLLocationManager = {
//        var manager = CLLocationManager()
//        manager.distanceFilter = 10
//        manager.desiredAccuracy = kCLLocationAccuracyBest
//        return manager
//    }()
//
//    func updateLocationOnMap(to location: CLLocation, with title: String?) {
//
//        let point = MKPointAnnotation()
//        point.title = title
//        point.coordinate = location.coordinate
//        self.mapView.removeAnnotations(self.mapView.annotations)
//        self.mapView.addAnnotation(point)
//
//        let viewRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
//        self.mapView.setRegion(viewRegion, animated: true)
//    }
//
//
//
//    @IBAction func setCurrentLocationAction() {
//
//        guard let currentLocation = locationManager.location
//            else { return }
//
//        currentLocation.lookUpLocationName { (name) in
//            self.updateLocationOnMap(to: currentLocation, with: name)
//        }
//    }
//
//    func setPinUsingMKPlacemark(location: CLLocationCoordinate2D) {
//       let pin = MKPlacemark(coordinate: location)
//       let coordinateRegion = MKCoordinateRegion(center: pin.coordinate, latitudinalMeters: 800, longitudinalMeters: 800)
//       mapView.setRegion(coordinateRegion, animated: true)
//       mapView.addAnnotation(pin)
//    }
//
//}
//
//extension MapViewController: CLLocationManagerDelegate {
//
//    func locationManager(_ manager: CLLocationManager,
//                         didChangeAuthorization status: CLAuthorizationStatus) {
//
//        if status == .authorizedWhenInUse || status == .authorizedAlways {
//            locationManager.startUpdatingLocation()
//        }
//    }
//}
//extension CLLocation {
//
//    func lookUpPlaceMark(_ handler: @escaping (CLPlacemark?) -> Void) {
//
//        let geocoder = CLGeocoder()
//
//        // Look up the location and pass it to the completion handler
//        geocoder.reverseGeocodeLocation(self) { (placemarks, error) in
//            if error == nil {
//                let firstLocation = placemarks?[0]
//                handler(firstLocation)
//            }
//            else {
//                // An error occurred during geocoding.
//                handler(nil)
//            }
//        }
//    }
//
//    func lookUpLocationName(_ handler: @escaping (String?) -> Void) {
//
//        lookUpPlaceMark { (placemark) in
//            handler(placemark?.country)
//        }
//    }
//}
//
////MARK: — MKMapView Delegate Methods
//extension ViewController: MKMapViewDelegate {
//   func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//
//    let Identifier = "Pin"
//      let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Identifier) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: Identifier)
//
//      annotationView.canShowCallout = true
//      if annotation is MKUserLocation {
//         return nil
//      } else if annotation is MKMapPoint{
//         annotationView.image =  UIImage(imageLiteralResourceName: "Pin")
//         return annotationView
//      } else {
//         return nil
//      }
//   }
//}


import UIKit
import MapKit
import GooglePlaces

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchController()
    }

    func setupSearchController() {
        resultsViewController = GMSAutocompleteResultsViewController()
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController

        let searchBar = searchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = searchController?.searchBar
        definesPresentationContext = true
        searchController?.hidesNavigationBarDuringPresentation = false
    }
    
}
