import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    private let geocoder = CLGeocoder() // Optional: Use Apple's Geocoder if needed

    @Published var userLocation: CLLocationCoordinate2D?
    @Published var userAddress: String? // Published property for the parsed address
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined // Track authorization status
    @Published var locationError: String? // Published error message for user feedback

    private let googleAPIKey = "" // Replace with your Google API Key
    private var lastSavedLocation: CLLocation? // Last location saved to UserDefaults
    private let significantDistance: Double = 50.0 // Distance threshold in meters

    override init() {
        super.init()
        locationManager.delegate = self
        requestAuthorization()
    }

    func requestAuthorization() {
        let status = locationManager.authorizationStatus
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            handleAuthorizationStatus(status)
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        handleAuthorizationStatus(status)
    }

    private func handleAuthorizationStatus(_ status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.locationManager.startUpdatingLocation()
            case .denied, .restricted:
                self.locationError = "Location access denied. Please enable it in settings."
            default:
                self.locationError = "Location services not available."
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            self.userLocation = location.coordinate

            // Check if the location change is significant
            if let lastLocation = lastSavedLocation {
                let distance = location.distance(from: lastLocation)
                print("Distance from last saved location: \(distance) meters")

                if distance > significantDistance {
                    fetchAddressWithGoogle(for: location)
                    lastSavedLocation = location
                }
            } else {
                // Save the first location
                fetchAddressWithGoogle(for: location)
                lastSavedLocation = location
            }
        } else {
            print("No location found in update.")
        }
    }

    func fetchAddressWithGoogle(for location: CLLocation) {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(latitude),\(longitude)&key=\(googleAPIKey)"

        guard let url = URL(string: urlString) else {
            print("Invalid URL for Google Geocoding API")
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                print("Error while fetching address from Google: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.userAddress = "Unknown Location"
                    self.locationError = "Google API Error: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                print("No data received from Google Geocoding API")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   let firstResult = results.first,
                   let formattedAddress = firstResult["formatted_address"] as? String,
                   let addressComponents = firstResult["address_components"] as? [[String: Any]] {

                    // Extract specific components
                    let streetName = addressComponents.first(where: { component in
                        guard let types = component["types"] as? [String] else { return false }
                        return types.contains("route") // "route" corresponds to street name in Google API
                    })?["long_name"] as? String ?? "N/A"

                    DispatchQueue.main.async {
                        self.userAddress = "\(streetName), \(formattedAddress)"
                        print("Parsed Address: \(self.userAddress!)")

                        // Save to UserDefaults only if the location has significantly changed
                        UserDefaults.standard.set(self.userAddress, forKey: "SavedUserAddress")
                    }
                } else {
                    print("No results found in Google Geocoding API")
                    DispatchQueue.main.async {
                        self.userAddress = "Unknown Location"
                    }
                }
            } catch {
                print("Error parsing JSON from Google Geocoding API: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.userAddress = "Unknown Location"
                    self.locationError = "Google API Parsing Error"
                }
            }
        }.resume()
    }

    func loadSavedAddress() -> String? {
        return UserDefaults.standard.string(forKey: "SavedUserAddress")
    }
}
