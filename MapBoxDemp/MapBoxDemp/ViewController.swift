//
//  ViewController.swift
//  MapBoxDemp
//
//  Created by Pritesh on 10/11/24.
//

import UIKit
import MapboxMaps
import CoreLocation

// Main view controller responsible for displaying the map and handling user location
class ViewController: UIViewController {
    
    // MARK: - Properties
    
    // MapView instance to display the map
    private var mapView: MapView!
    
    // CLLocationManager instance to manage location services
    private let locationManager = CLLocationManager()
    
    // Custom location provider for more control over location settings
    private let locationProvider = AppleLocationProvider()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure and display the Mapbox map
        setupMapView()
        
        // Configure location manager and request user permissions
        setupLocationManager()
    }
    
    // MARK: - Setup Methods
    
    /// Configures the Mapbox map view and adds it to the main view
    private func setupMapView() {
        let mapInitOptions = MapInitOptions(styleURI: StyleURI.streets)
        
        // Initialize the MapView with options
        mapView = MapView(frame: view.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Add MapView to the main view
        view.addSubview(mapView)
        
        // Hide the Mapbox attribution and scale bar by moving them off-screen
        hideMapOrnaments()
        
        // Setup Current Location Button with an image
        let currentLocationButton = UIButton(type: .custom) // Create a button with custom style
        if let locationIcon = UIImage(named: "ic_currentLocationIcon") {
            currentLocationButton.setImage(locationIcon, for: .normal) // Set the image for the button
        }

        // Use Auto Layout to position the button at the top-right corner of the view
        currentLocationButton.translatesAutoresizingMaskIntoConstraints = false // Disable autoresizing mask for auto layout
        self.view.addSubview(currentLocationButton) // Add the button to the view

        // Apply constraints to position the button at the top-right corner
        NSLayoutConstraint.activate([
            // Position the button 30 points from the top of the safe area
            currentLocationButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 30),
            
            // Position the button 20 points from the right edge of the safe area (trailing)
            currentLocationButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            // Set a fixed width of 40 points for the button (adjustable based on your image size)
            currentLocationButton.widthAnchor.constraint(equalToConstant: 40),
            
            // Set a fixed height of 40 points for the button (adjustable based on your image size)
            currentLocationButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        // Add target action for button tap, to call the 'centerOnCurrentLocation' method when tapped
        currentLocationButton.addTarget(self, action: #selector(userCurrentLocationTapped(_:)), for: .touchUpInside)
    }
    // Method to center and zoom map on the current location
  
    @IBAction func userCurrentLocationTapped(_ sender: UIButton) {
        // Ensure the user location is available
        guard let userLocation = locationManager.location else {
            print("User location is not available")
            return
        }

        // Set the camera to the user's location with desired zoom level
        let cameraOptions = CameraOptions(center: userLocation.coordinate, zoom: 14)
        mapView.mapboxMap.setCamera(to: cameraOptions)
    }
    /// Hides the map attribution and scale bar by positioning them off-screen
    private func hideMapOrnaments() {
        // Attribution button
        mapView.ornaments.options.attributionButton.position = .bottomTrailing
        mapView.ornaments.options.attributionButton.margins = CGPoint(x: -100, y: -100) // Move off-screen
        
        // Scale bar
        mapView.ornaments.options.scaleBar.position = .topLeft
        mapView.ornaments.options.scaleBar.margins = CGPoint(x: -100, y: -100) // Move off-screen
    }
    
    /// Configures CLLocationManager for location services and requests authorization
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - Helper Methods
    
    /// Centers the map on the user's current location with a smooth animation
    private func centerMapOnUserLocation(with coordinate: CLLocationCoordinate2D) {
        mapView.mapboxMap.setCamera(to: CameraOptions(center: coordinate, zoom: 14))
        
        // Optionally, show a custom user location annotation on the map
        addUserLocationAnnotation(at: coordinate)
    }
    
    /// Adds a custom annotation (e.g., a dot or marker) at the user's location on the map
    private func addUserLocationAnnotation(at coordinate: CLLocationCoordinate2D) {
        // Ensure the custom image is available in assets
        guard let image = UIImage(named: "ic_locationIcon") else {
            print("Error: Custom image 'ic_locationIcon' not found in assets.")
            return
        }
        
        // Register the image with the map style
        do {
            try mapView.mapboxMap.style.addImage(image, id: "ic_locationIcon")
        } catch {
            print("Error adding image to map style: \(error)")
            return
        }
        
        // Create a point annotation with the user's location coordinate
        var pointAnnotation = PointAnnotation(coordinate: coordinate)
        pointAnnotation.image = .init(image: image, name: "ic_locationIcon")
        
        // Add the annotation to the map
        let annotationManager = mapView.annotations.makePointAnnotationManager()
        annotationManager.annotations = [pointAnnotation]
    }
}

// MARK: - CLLocationManagerDelegate

extension ViewController: CLLocationManagerDelegate {
    
    /// Handles changes in location authorization status
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            DispatchQueue.main.async {
                if CLLocationManager.locationServicesEnabled() {
                    // Start updating location when services are enabled
                    self.locationManager.startUpdatingLocation()
                    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                } else {
                    print("Location services are not enabled.")
                }
            }
        case .denied, .restricted:
            print("Location access denied or restricted.")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            print("Unknown authorization status.")
        }
    }
    
    /// Called when the user's location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Center map on the user's current location
        centerMapOnUserLocation(with: location.coordinate)
    }
    
    /// Handles errors in location updates
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }
}

// MARK: - AppleLocationProviderDelegate

extension ViewController: AppleLocationProviderDelegate {
    
    /// Handles errors in the custom location provider
    func appleLocationProvider(_ locationProvider: AppleLocationProvider, didFailWithError error: Error) {
        print("Location provider error: \(error.localizedDescription)")
    }
    
    /// Determines whether to display a heading calibration alert
    func appleLocationProviderShouldDisplayHeadingCalibration(_ locationProvider: AppleLocationProvider) -> Bool {
        return true
    }
    
    /// Handles changes in accuracy authorization
    func appleLocationProvider(_ locationProvider: AppleLocationProvider, didChangeAccuracyAuthorization accuracyAuthorization: CLAccuracyAuthorization) {
        if accuracyAuthorization == .reducedAccuracy {
            // Perform actions in response to reduced accuracy, if needed
            print("Location accuracy authorization changed to reduced accuracy.")
        }
    }
}
