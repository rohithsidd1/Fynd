import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var locationFetcher = LocationFetcher()

    @State private var selectedIndex = 0 // Track the current card index
    @State private var selectedRadius: Int = 5000 // Default radius in meters
    @State private var selectedLocationType: LocationFetcher.LocationType = .restaurant // Default location type
    @State private var displayedText: String = "" // Typing animation text
    @State private var showCursor = true // State for cursor visibility
    @State private var isScrollAtTop = true // Track whether the scroll is at the top
    @State private var showLocationChangeView = false // State to control the sheet

    private let typingSpeed = 0.1 // Typing speed in seconds
    private let cardSpacing: CGFloat = 30.0
    private let cardScale: CGFloat = 0.85

    let radiusOptions = [1000, 5000, 10000, 20000, 50000, 100000] // Radius options
    let locationTypes: [LocationFetcher.LocationType] = [
        .restaurant, .shop, .hotel, .park, .museum, .library,
        .mall, .cafe, .hospital, .pharmacy, .theater, .stadium,
        .school, .university, .zoo, .amusementPark, .culturalInstitution,
        .gasStation, .atm, .postOffice, .bank, .church, .mosque,
        .temple, .clinic, .pub, .brewery, .bars, .gyms, .hostels, .pg,
        .livemusic, .supermarts, .electronics, .rentals, .martialarts, .viewpoints, .metros, .bus, .railway
    ]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Background Gradient
                Color(red: 37 / 255, green: 71 / 255, blue: 116 / 255, opacity: 0.3)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 0) {
                    
                    // Fixed Top Section
                    VStack(spacing: 0) {
                        // Animated Header Section
                        if isScrollAtTop{
                            HStack {
                                Button(action: {
                                    showLocationChangeView = true // Show the location change view
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "mappin")
                                            .font(.headline)

                                        VStack(alignment: .leading, spacing: 2) {
                                            if let address = locationManager.userAddress {
                                                let addressParts = address.split(separator: ",", maxSplits: 2, omittingEmptySubsequences: true)
                                                if addressParts.indices.contains(1) {
                                                    HStack(spacing: 4){
                                                        Text(String(addressParts[1])) // Second line after the first comma
                                                            .font(.custom("Lexend-Medium", size: 16))
                                                            .multilineTextAlignment(.leading)
                                                        
                                                        Image(systemName: "chevron.down")
                                                            .font(.footnote)
                                                    }
                                                }
                                                if addressParts.indices.contains(2) {
                                                    Text(String(addressParts[2])) // Remaining address
                                                        .font(.custom("Lexend-Regular", size: 14))
                                                        .foregroundColor(.secondary)
                                                        .multilineTextAlignment(.leading)
                                                        .lineLimit(1)

                                                }
                                            } else {
                                                Text("Fetching address...")
                                                    .font(.custom("Lexend-Medium", size: 16))
                                            }
                                        }
                                    }
                                    .foregroundColor(.primary)
                                }
                                .sheet(isPresented: $showLocationChangeView) {
                                    ManualLocationChangeView(
                                        locationFetcher: locationFetcher,
                                        radius: selectedRadius,
                                        locationType: selectedLocationType,
                                        locationManager: locationManager // Pass locationManager here
                                    )
                                }

                                Spacer()
                                
                                
                                Button(action: {
                                    // Add message action here
                                }) {
                                    Image(systemName: "bell")
                                        .foregroundColor(.primary)
                                        .padding(12)
                                        .background(.ultraThinMaterial)
                                        .clipShape(Circle())
                                }
                                
                                Button(action: {
                                    // Add message action here
                                }) {
                                    Image(systemName: "message")
                                        .foregroundColor(.primary)
                                        .padding(12)
                                        .background(Color(red: 37 / 255, green: 71 / 255, blue: 116 / 255, opacity: 1.0))
                                        .clipShape(Circle())
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        UltraThinSearchBar(searchText: .constant("")) // Bind this to your state if needed


                        // Floating Picker: SearchSortScrollView
                        SearchSortScrollView(
                            selectedLocationType: $selectedLocationType,
                            selectedRadius: $selectedRadius,
                            locationTypes: locationTypes,
                            locationManager: locationManager,
                            locationFetcher: locationFetcher,
                            isTabView: !isScrollAtTop // Show tab-like UI when scrolled down
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.easeInOut, value: isScrollAtTop)
                    }

                    // Scrollable Content
                    ScrollView {
                        GeometryReader { geo in
                            Color.clear
                                .onChange(of: geo.frame(in: .global).minY) { newValue in
                                    withAnimation {
                                        isScrollAtTop = newValue >= 188 // Update `isScrollAtTop` based on scroll position
                                    }
                                }
                        }
                        .frame(height: 0) // Invisible frame for tracking scroll

                        VStack(spacing: 0) {
                            if let userLocation = locationManager.userLocation {
                                ZStack {
                                    ForEach(locationFetcher.locations.indices, id: \.self) { index in
                                        LocationCardView(
                                            location: locationFetcher.locations[index],
                                            selectedRadius: $selectedRadius,
                                            userLocation: userLocation,
                                            locationFetcher: locationFetcher
                                        )
                                        .zIndex(zIndex(for: index))
                                        .scaleEffect(scale(for: index))
                                        .offset(x: offset(for: index), y: yOffset(for: index))
                                        .opacity(opacity(for: index))
                                        .animation(
                                            .spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0.3),
                                            value: selectedIndex
                                        )
                                        .gesture(
                                            DragGesture()
                                                .onEnded { gesture in
                                                    if gesture.translation.width < -50, selectedIndex < locationFetcher.locations.count - 1 {
                                                        selectedIndex += 1
                                                        checkAndLoadNextPage()
                                                    } else if gesture.translation.width > 50, selectedIndex > 0 {
                                                        selectedIndex -= 1
                                                    }
                                                }
                                        )
                                    }
                                }
                                .onAppear {
                                    // Check if locations are already cached
                                    if locationFetcher.locations.isEmpty {
                                        locationFetcher.fetchLocations(
                                            latitude: userLocation.latitude,
                                            longitude: userLocation.longitude,
                                            radius: selectedRadius,
                                            type: selectedLocationType
                                        )
                                    }
                                }
                                
                                // Show FavoriteTabView only after LocationCardView is ready
                                if !locationFetcher.locations.isEmpty {
                                    FavoriteTabView(userLocation: locationManager.userLocation ?? CLLocationCoordinate2D(), locationFetcher: locationFetcher)
                                        .padding(.top)
                                }
                            } else {

                            }
                        }
                    }
                    .scrollIndicators(.never)
                }
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        // Custom Picker for Radius
                        CustomPicker(selectedValue: $selectedRadius, options: radiusOptions, title: "")
                            .onChange(of: selectedRadius) { newValue in
                                if let userLocation = locationFetcher.userLocationManuallySet ?? locationManager.userLocation {
                                    locationFetcher.fetchLocations(
                                        latitude: userLocation.latitude,
                                        longitude: userLocation.longitude,
                                        radius: newValue,
                                        type: selectedLocationType
                                    )
                                }
                            }
                    }
                }
            }
        }
    }

    // MARK: - Pagination Logic

    private func checkAndLoadNextPage() {
        if selectedIndex == locationFetcher.locations.count - 1 {
            if let userLocation = locationManager.userLocation {
                locationFetcher.fetchLocations(
                    latitude: userLocation.latitude,
                    longitude: userLocation.longitude,
                    radius: selectedRadius,
                    type: selectedLocationType,
                    isNextPage: true // Signal to fetch the next page
                )
            }
        }
    }

    // MARK: - Card Positioning Helpers

    private func zIndex(for index: Int) -> Double {
        return index == selectedIndex ? 1 : 0
    }

    private func scale(for index: Int) -> CGFloat {
        return index == selectedIndex ? 1.0 : cardScale
    }

    private func offset(for index: Int) -> CGFloat {
        if index < selectedIndex {
            return -200 + CGFloat(index - selectedIndex) * cardSpacing
        } else if index > selectedIndex {
            return 200 + CGFloat(index - selectedIndex) * cardSpacing
        } else {
            return 0
        }
    }

    private func yOffset(for index: Int) -> CGFloat {
        return index == selectedIndex ? 0 : 20
    }

    private func opacity(for index: Int) -> Double {
        return index == selectedIndex ? 1.0 : 0.9
    }
}


import SwiftUI
import CoreLocation

struct ManualLocationChangeView: View {
    @ObservedObject var locationFetcher: LocationFetcher
    @State private var manualAddress: String = "" // State for the entered address
    @State private var errorMessage: String? = nil // State for any error messages
    @Environment(\.presentationMode) var presentationMode // For dismissing the view
    let radius: Int
    let locationType: LocationFetcher.LocationType
    @ObservedObject var locationManager: LocationManager


    var body: some View {
        NavigationView {
            VStack {
                Text("Change Your Location")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()

                TextField("Enter your address", text: $manualAddress)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.top, 4)
                }

                Button(action: {
                    handleAddressChange()
                }) {
                    Text("Save Location")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()

                Spacer()
            }
            .navigationTitle("Manual Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }

    private func handleAddressChange() {
        guard !manualAddress.isEmpty else {
            errorMessage = "Please enter a valid address."
            return
        }

        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(manualAddress) { placemarks, error in
            if let error = error {
                errorMessage = "Failed to find the location: \(error.localizedDescription)"
                return
            }

            if let placemark = placemarks?.first, let location = placemark.location {
                DispatchQueue.main.async {
                    // Update the LocationFetcher directly
                    locationFetcher.updateUserLocationManually(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude,
                        radius: radius,
                        type: locationType
                    )
                    
                    locationManager.userLocation = location.coordinate
                    locationManager.userAddress = [
                        placemark.name,
                        placemark.thoroughfare,
                        placemark.subThoroughfare,
                        placemark.subLocality,
                        placemark.locality,
                        placemark.administrativeArea,
                        placemark.postalCode,
                        placemark.country
                    ]
                    .compactMap { $0 }
                    .joined(separator: ", ")

                    presentationMode.wrappedValue.dismiss() // Dismiss the view
                }
            } else {
                errorMessage = "No valid location found."
            }
        }
    }
}
