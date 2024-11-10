# MapboxSDK_Pritesh
mapbox SDK Example with user current location


import Foundation
Mapbox iOS App - User Location Tracker
This iOS app uses Mapbox Maps SDK to display a map and allows users to view their current location on the map. A custom button is provided to center the map on the user's location. The app also adds a custom marker for the user's location.

Features:
Map Display: Displays a Mapbox map with the "Streets" style.
User Location: Displays and tracks the user's current location.
Current Location Button: A custom button to center the map on the user's current location.
Location Marker: Adds a custom marker on the user's location.
Location Accuracy: Handles user location updates with configurable accuracy.
Location Permissions: Requests and manages location permissions using CLLocationManager.
Prerequisites:
Xcode 14.0 or higher
An Apple Developer account (for location services and map usage)
Setup Instructions:
1. Clone the Repository:
git clone https://github.com/raiyanipritesh1990/MapboxSDK_Pritesh.git
2. Install Dependencies:
This project uses Mapbox Maps SDK. To install it:

Open the .xcworkspace file with Xcode.
If you are using CocoaPods:
Navigate to your project directory and run the following in the terminal:
pod install
Open the .xcworkspace file in Xcode to use the installed pods.

3. Configure Mapbox:
Sign up at Mapbox to get an API key.
Replace the Mapbox API key in the MapView initialization (if needed).
4. Permissions:
Ensure that your Info.plist includes the necessary permissions to access the user's location:

xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show it on the map</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>We need your location to track it on the map</string>

5. Build & Run:
Build and run the project on a physical iOS device (since location services are not available on simulators).
The app will request location access and display the map with a button to center on the current location.
How it Works:
Map Initialization: A MapView is created with the "Streets" style from Mapbox.
Location Manager: The app uses CLLocationManager to request and handle location updates.
User Location Button: A custom button is placed at the top-right corner of the screen, and upon tapping, it centers the map on the user's current location.
Location Updates: The app continuously updates the user's location and re-centers the map as the user moves.
Custom Marker: A custom location icon is added as a point annotation to represent the user's location on the map.
Button Customization:
The button uses an image named "ic_currentLocationIcon". Ensure the image exists in your assets.
You can adjust the size and position of the button via the constraints set in the code.
Code Details:
MapView from Mapbox SDK is used to display the map.
CLLocationManager is used to handle user location updates and request authorization.
The button uses Auto Layout to position it at the top-right corner of the screen.
Custom markers (PointAnnotation) are used to mark the user’s location on the map.

Example of Button Setup:

let currentLocationButton = UIButton(type: .custom)
if let locationIcon = UIImage(named: "ic_currentLocationIcon") {
    currentLocationButton.setImage(locationIcon, for: .normal)
}

Location Manager Configuration:
private func setupLocationManager() {
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
}
Map Camera Control:
let cameraOptions = CameraOptions(center: userLocation.coordinate, zoom: 14)
mapView.mapboxMap.setCamera(to: cameraOptions)
