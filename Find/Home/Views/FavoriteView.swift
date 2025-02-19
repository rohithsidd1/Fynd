import SwiftUI
import MapKit

struct FavoriteLocationCardView: View {
    @ObservedObject var viewModel: LocationCardViewModel
    var userLocation: CLLocationCoordinate2D

    init(location: Location, userLocation: CLLocationCoordinate2D) {
        self.viewModel = LocationCardViewModel(location: location)
        self.userLocation = userLocation
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack(alignment: .topTrailing) {
                // Card Background Image
                if let imageUrl = viewModel.location.imageUrl, let url = URL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=1600&photoreference=\(imageUrl)&key=AIzaSyAELiwUuzrOY2aJmxODxdIyTfa5MCJ5eeY") {
                    CachedAsyncImage(url: url)
                        .frame(width: UIScreen.main.bounds.width * 0.8, height: 300)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    // Placeholder for missing image
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray)
                        .frame(width: UIScreen.main.bounds.width * 0.8, height: 300)
                }

                // Like Button (top-right corner)
                Button(action: {
                    viewModel.toggleLike() // Call ViewModel method to toggle like status
                }) {
                    Image(systemName: viewModel.isLiked ? "heart.fill" : "heart") // Toggle between heart.fill and heart
                        .foregroundColor(viewModel.isLiked ? .red : .white) // Set red color for filled heart, white for empty heart
                        .font(.headline)
                        .padding(10)
                        .background(.ultraThinMaterial) // Semi-transparent background
                        .clipShape(Circle())
                }
                .padding([.top, .trailing])
            }

            VStack(alignment: .leading) {
                // Location Name
                HStack{
                    Text(viewModel.location.name)
                        .font(.custom("Lexend-SemiBold", size: 18))
                        .foregroundColor(.primary)

                    Spacer()
                    // Distance
                    let location = CLLocation(latitude: viewModel.location.latitude, longitude: viewModel.location.longitude)
                    let userLocationCL = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
                    let distance = userLocationCL.distance(from: location) // Distance in meters
                    let distanceInKm = distance / 1000 // Convert to kilometers

                    HStack(spacing: 4) {
                        Image(systemName: "location.north.fill")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        Text(String(format: "%.2f km", distanceInKm))
                            .font(.custom("Lexend-Regular", size: 14))
                            .foregroundColor(.primary)
                    }

                }

                HStack {
                    
                    HStack(spacing: 2){
                        // Clock image next to the text
                        Image(systemName: "clock.fill")
                            .foregroundColor(
                                // Set the clock color based on the status
                                (viewModel.location.openingHours?.openNow ?? false) ? .green.opacity(0.7) : .primary.opacity(0.7)
                            )
                            .font(.caption) // Adjust size of the clock icon
                        
                        // Open/Closed status with color change for open and closed
                        if let openingStatus = viewModel.location.openingHours?.openNow {
                            Text(openingStatus ? "Open Now." : "Closed.")
                                .foregroundColor(openingStatus ? .green.opacity(0.7) : .primary.opacity(0.7)) // Green if open, red if closed
                                .font(.custom("Lexend-Regular", size: 14)) // Apply your custom font
                        } else {
                            Text("Opening hours data not available")
                                .foregroundColor(.primary.opacity(0.7)) // Gray for unavailable data
                                .font(.custom("Lexend-Regular", size: 14)) // Apply your custom font
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.footnote)
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", viewModel.location.rating ?? 0.0))
                                .foregroundColor(.primary)
                                .font(.custom("Lexend-Regular", size: 14)) // Use your custom font
                        }

                    }
                }

                HStack {
                    
                    // Address
                    Text(viewModel.location.address)
                        .font(.custom("Lexend-Regular", size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(2)

                    Spacer()
                    // "View" Button
                    NavigationLink(destination: LocationDetailView(location: viewModel.location, userLocation: userLocation)) {
                        HStack(spacing: 4) {
                            Text("View")
                            Image(systemName: "chevron.forward")
                        }
                        .font(.custom("Lexend-Semibold", size: 14))
                        .foregroundColor(.black)
                        .padding(8)
                        .background(Color.white)
                        .cornerRadius(20)
                    }
                }
            }
            .padding()
            .frame(width: UIScreen.main.bounds.width * 0.8) // Adjusted height for content alignment
            .background(.ultraThinMaterial)
            .cornerRadius(12)
        }
        .padding(.horizontal, 8)
    }
}


import SwiftUI
import MapKit

struct FavoriteTabView: View {
    @State private var likedLocations: [Location] = [] // Array of liked locations
    var userLocation: CLLocationCoordinate2D
    var locationFetcher: LocationFetcher

    init(userLocation: CLLocationCoordinate2D, locationFetcher: LocationFetcher) {
        self.userLocation = userLocation
        self.locationFetcher = locationFetcher
    }

    var body: some View {
        VStack(spacing: 0){
            HStack{
                Text("Liked Places ❤️")
                    .font(.custom("Lexend-Medium", size: 28))
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                    .padding(.top)
                
                Spacer()
            }

            if likedLocations.isEmpty {
                VStack{
                    ZStack {
                        // Background Lottie Animation
                        LottieView(name: "FavEmp", loopMode: .playOnce)
                            .frame(width: 200, height: 200)
                        
                        // Text Overlay
                        VStack {
                            Text("No Favorites Yet!")
                                .font(.custom("Lexend-Regular", size: 18))
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary.opacity(0.7))
                            
                            Text("Like your favorite places and come back >.<")
                                .font(.custom("Lexend-Light", size: 14))
                                .foregroundStyle(.primary.opacity(0.5))
                        }
                        .padding(.top, 182)
                    }
                    .padding(.bottom, 32)
                }
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .cornerRadius(8)
                .padding()
                
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(likedLocations, id: \.id) { location in
                            FavoriteLocationCardView(location: location, userLocation: userLocation)
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            // Fetch liked locations
            let likedLocationIDs = LikedLocationManager.getLikedLocations()
            likedLocations = []

            for id in likedLocationIDs {
                locationFetcher.getLocationById(id) { location in
                    if let location = location, !likedLocations.contains(where: { $0.id == location.id }) {
                        likedLocations.append(location)
                    }
                }
            }
        }
    }
}
