import SwiftUI
import MapKit

struct LocationCardView: View {
    @ObservedObject var viewModel: LocationCardViewModel
    @Binding var selectedRadius: Int
    var userLocation: CLLocationCoordinate2D
    var locationFetcher: LocationFetcher
    @State private var isLoading = true // State to toggle shimmer effect

    init(location: Location, selectedRadius: Binding<Int>, userLocation: CLLocationCoordinate2D, locationFetcher: LocationFetcher) {
        self.viewModel = LocationCardViewModel(location: location)
        self._selectedRadius = selectedRadius
        self.userLocation = userLocation
        self.locationFetcher = locationFetcher
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            if isLoading {
                ShimmeringRectangle()
                    .frame(height: 480)
                    .cornerRadius(20)
                    .onAppear {
                        // Simulate loading delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isLoading = false
                        }
                    }
            } else {
                ZStack(alignment: .topTrailing) {
                    // Card Background Image
                    if let imageUrl = viewModel.location.imageUrl, let url = URL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=1600&photoreference=\(imageUrl)&key=") {
                        CachedAsyncImage(url: url)
                            .frame(width: UIScreen.main.bounds.width * 0.9, height: 480)
                            .clipped()
                            .cornerRadius(20)
                    } else {
                        // Placeholder for missing image
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray)
                            .frame(height: 480)
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
                    HStack{
                        Text(viewModel.location.name)
                            .font(.custom("Lexend-SemiBold", size: 20)) // Use your custom font
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        
                        let location = CLLocation(latitude: viewModel.location.latitude, longitude: viewModel.location.longitude)
                        let userLocationCL = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
                        
                        // Calculate the distance between the user's location and the location
                        let distance = userLocationCL.distance(from: location) // Distance in meters
                        let distanceInKm = distance / 1000 // Convert to kilometers
                        
                        // Format the distance as a string (e.g., "3.45 km")
                        let distanceString = String(format: "%.2f km", distanceInKm)
                        
                        HStack(spacing: 2) {
                            Image(systemName: "location.north.fill")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            Text("\(distanceString)") // Display the distance text
                                .font(.custom("Lexend-Regular", size: 14)) // Use your custom font
                                .foregroundColor(.primary)
                        }
                        
                    }
                    
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
                    
                    
                    HStack {
                        HStack {
                            Image(systemName: "mappin.and.ellipse") // The SF Symbol icon
                                .foregroundColor(Color.primary.opacity(0.7))
                            Text(viewModel.location.address) // The text for the label
                                .font(.custom("Lexend-Regular", size: 12)) // Apply your custom font
                                .foregroundColor(Color.primary.opacity(0.7))
                                .multilineTextAlignment(.leading)
                            
                        }
                        Spacer()
                        
                        NavigationLink(destination: LocationDetailView(location: viewModel.location, userLocation: userLocation)) {
                            HStack(spacing: 4) {
                                Text("View")
                                Image(systemName: "chevron.forward")
                            }
                            .foregroundColor(.black) // Set the text and icon color
                            .font(.custom("Lexend-Semibold", size: 14)) // Apply your custom font
                            .padding(8)
                            .background(Color.white) // Background color
                            .cornerRadius(20) // Rounded corners
                        }
                        
                    }
                    .font(.caption)
                    .padding(.top,8)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .padding(.horizontal, 3)
                
            }
        }
        .padding(.horizontal)
    }
}


// MARK: - Shimmer View
struct ShimmerView: View {
    @State private var isAnimating = false

    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.6), Color.gray.opacity(0.3)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .opacity(0.5)
            .mask(
                Rectangle()
                    .fill(LinearGradient(gradient: Gradient(colors: [.clear, .black, .clear]), startPoint: .leading, endPoint: .trailing))
                    .rotationEffect(.degrees(30))
                    .offset(x: isAnimating ? 300 : -300)
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}
