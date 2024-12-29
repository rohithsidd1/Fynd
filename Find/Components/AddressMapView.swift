import SwiftUI
import MapKit

struct AddressAndDistanceView: View {
    let address: String
    let location: CLLocation
    let userLocation: CLLocationCoordinate2D

    @State private var showFullScreenMap = false // State to control the full-screen map

    var body: some View {
        VStack {
            HStack {
                Label(address, systemImage: "mappin.and.ellipse")
                    .font(.custom("Lexend-Regular", size: 14)) // Apply your custom font

                Spacer()

                // Calculate the distance between the user's location and the location
                let userLocationCL = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
                let distance = userLocationCL.distance(from: location) // Distance in meters
                let distanceInKm = distance / 1000 // Convert to kilometers

                // Format the distance as a string (e.g., "3.45 km")
                let distanceString = String(format: "%.2f km", distanceInKm)

                HStack(spacing: 4) {
                    Image(systemName: "location.north.fill")
                        .font(.footnote)
                    Text("\(distanceString)") // Display the distance text
                        .font(.custom("Lexend-Regular", size: 14)) // Apply your custom font
                }
            }
            .padding(.top, 32)
            .padding(.horizontal)
            .foregroundColor(.primary.opacity(0.7))
            

            // Create an annotation item
            let annotation = LocationAnnotation(coordinate: location.coordinate)

            // Map preview with a transparent overlay
            ZStack {
                Map(coordinateRegion: .constant(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude),
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )), annotationItems: [annotation]) { annotation in
                    MapPin(coordinate: annotation.coordinate, tint: .red)
                }
                .frame(height: 200)
                .cornerRadius(10)
                .padding(.top, 4)
                .padding(.horizontal)
                .allowsHitTesting(false) // Prevent map interactions

                // Transparent overlay to intercept tap gestures
                Rectangle()
                    .foregroundColor(.white.opacity(0.001)) // Fully transparent
                    .frame(height: 200)
                    .cornerRadius(10)
                    .padding(.top, 4)
                    .padding(.horizontal)
                    .onTapGesture {
                        showFullScreenMap = true
                    }
            }

            // Full-screen map with back button
            .fullScreenCover(isPresented: $showFullScreenMap) {
                FullScreenMapContainerView(
                    destination: location.coordinate,
                    userLocation: userLocation
                )
            }
        }
    }
}
