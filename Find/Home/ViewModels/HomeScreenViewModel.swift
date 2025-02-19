import Foundation
import CoreLocation
import Combine

class ContentViewModel: ObservableObject {
    @Published var selectedIndex = 0 // Track the current card index
    @Published var selectedRadius: Int = 5000 // Default radius in meters
    @Published var selectedLocationType: LocationFetcher.LocationType = .restaurant // Default location type
    @Published var isScrollAtTop = true // Track whether the scroll is at the top
    @Published var displayedText: String = "Heyo, Rohith!"
    @Published var showCursor = true
    @Published var userAddress: String = "Fetching location..." // User's address

    private let typingSpeed = 0.1 // Typing speed in seconds
    private let cardSpacing: CGFloat = 30.0
    private let cardScale: CGFloat = 0.85

    private let locationManager: LocationManager
    private let locationFetcher: LocationFetcher

    init(locationManager: LocationManager, locationFetcher: LocationFetcher) {
        self.locationManager = locationManager
        self.locationFetcher = locationFetcher
        startTypingAnimation()
        fetchUserAddress()
    }

    // MARK: - Fetch User Address
    func fetchUserAddress() {
        guard let userLocation = locationManager.userLocation else { return }
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)

        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Error reverse geocoding: \(error)")
                return
            }
            guard let placemark = placemarks?.first else {
                DispatchQueue.main.async {
                    self.userAddress = "Unknown location"
                }
                return
            }
            DispatchQueue.main.async {
                self.userAddress = [
                    placemark.subLocality,
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.country
                ]
                .compactMap { $0 }
                .joined(separator: ", ")
            }
        }
    }

    // MARK: - Typing Animation
    private func startTypingAnimation() {
        displayedText = "Heyo, Rohith!"
        showCursor = true
        var currentIndex = 0

        Timer.scheduledTimer(withTimeInterval: typingSpeed, repeats: true) { timer in
            if currentIndex < self.displayedText.count {
                currentIndex += 1
            } else {
                timer.invalidate() // Stop the timer when typing is complete
                self.startCursorBlinking() // Start cursor blinking after typing is done
            }
        }
    }

    private func startCursorBlinking() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            DispatchQueue.main.async {
                self.showCursor.toggle()
            }
        }
    }

    // MARK: - Card Helpers
    func zIndex(for index: Int) -> Double {
        return index == selectedIndex ? 1 : 0
    }

    func scale(for index: Int) -> CGFloat {
        return index == selectedIndex ? 1.0 : cardScale
    }

    func offset(for index: Int) -> CGFloat {
        if index < selectedIndex {
            return -200 + CGFloat(index - selectedIndex) * cardSpacing
        } else if index > selectedIndex {
            return 200 + CGFloat(index - selectedIndex) * cardSpacing
        } else {
            return 0
        }
    }

    func yOffset(for index: Int) -> CGFloat {
        return index == selectedIndex ? 0 : 20
    }

    func opacity(for index: Int) -> Double {
        return index == selectedIndex ? 1.0 : 0.9
    }
}
