//
//  CoordinatesViewController.swift
//  MobileiOS
//
//  Created by George on 03.01.2021.
//

import UIKit
import MapKit
import GooglePlaces

class CoordinatesViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    
    var searchController: UISearchController!
    
    var itemId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchController()
        
        resultsViewController?.delegate = self
        
        checkIfCoordinatesExist()
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
    
    func checkIfCoordinatesExist() {
        DatabaseManager.manager.downloadItemLocation(itemId: itemId!) { [weak self] (result) in
            guard let strongSelf = self else { return }
            switch result {
            case.success(let coordinates):
                strongSelf.addExistingAnnotation(latitude: coordinates.latitude, longitude: coordinates.longitude, title: coordinates.title, subtitle: coordinates.subtitle)
            case.failure(let error):
                print("No coordinates found")
            }
        }
    }
    
    func addExistingAnnotation(latitude: String, longitude: String, title: String, subtitle: String) {
        
        let placeCoordinates = CLLocationCoordinate2D(latitude: Double(latitude) ?? 0.0, longitude: Double(longitude) ?? 0.0)
        // 2
        mapView.removeAnnotations(mapView.annotations)

        // 3
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placeCoordinates, span: span)
        mapView.setRegion(region, animated: true)

        // 4
        let annotation = MKPointAnnotation()
        annotation.coordinate = placeCoordinates
        annotation.title = title
        annotation.subtitle = subtitle
                
        mapView.addAnnotation(annotation)
    }
    
    
}

extension CoordinatesViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        print("BOSSSSSSSSSS")
        // 1
        searchController?.isActive = false

        // 2
        mapView.removeAnnotations(mapView.annotations)

        // 3
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: place.coordinate, span: span)
        mapView.setRegion(region, animated: true)

        // 4
        let annotation = MKPointAnnotation()
        annotation.coordinate = place.coordinate
        annotation.title = place.name
        annotation.subtitle = place.formattedAddress
        
        print(place.coordinate.latitude.description)
        guard let safeItemId = itemId else { return }
        DatabaseManager.manager.markItemLocation(itemId: safeItemId, latitude: place.coordinate.latitude.description, longitude: place.coordinate.longitude.description , title: place.name ?? "Marked location", subtitle: place.formattedAddress ?? "")
        
        mapView.addAnnotation(annotation)
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}
