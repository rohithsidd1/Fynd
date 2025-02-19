import SwiftUI
import MapKit

struct LocationDetailView: View {
    var location: Location
    var userLocation: CLLocationCoordinate2D
    @StateObject private var viewModel: LocationCardViewModel

    @Environment(\.presentationMode) var presentationMode // Environment variable to control navigation

    init(location: Location, userLocation: CLLocationCoordinate2D) {
        self.location = location
        self.userLocation = userLocation
        _viewModel = StateObject(wrappedValue: LocationCardViewModel(location: location))
    }

    var body: some View {
        VStack{
            ScrollView {
                VStack(spacing:0){
                    if let imageUrl = viewModel.location.imageUrl, let url = URL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=1600&photoreference=\(imageUrl)&key=") {
                        CachedAsyncImage(url: url)
                            .scaledToFill()
                            .clipped()
//                            .cornerRadius(20)
                    } else {
                        RoundedRectangle(cornerRadius: 0)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 250)
                    }
                    
                    VStack(spacing:0){
                        VStack(spacing: 6){
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(viewModel.location.name)
                                        .font(.custom("Lexend-SemiBold", size: 24)) // Use your custom font
                                    
                                    Text(viewModel.about)
                                        .font(.custom("Lexend-Light", size: 14)) // Use your custom font
                                        .foregroundColor(.primary.opacity(0.6))
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    viewModel.isLiked.toggle() // Toggle the like state
                                }) {
                                    Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                                        .foregroundColor(viewModel.isLiked ? .red : .primary)
                                        .font(.subheadline)
                                        .padding(10)
                                        .background(.ultraThinMaterial)
                                        .clipShape(Circle())
                                }
                            }
                            .padding(.top)
                            .padding(.horizontal)
                            
                            StatusAndRatingView(
                                isOpenNow: viewModel.location.openingHours?.openNow,
                                rating: viewModel.location.rating
                            )
                            
                            DetailsView(
                                phone: viewModel.parseDetail(from: viewModel.details, for: "Phone"),
                                website: viewModel.parseDetail(from: viewModel.details, for: "Website")
                            )
                            .padding(.top)
                            
                        }
                        
                        AddressAndDistanceView(
                            address: viewModel.location.address,
                            location: CLLocation(latitude: viewModel.location.latitude, longitude: viewModel.location.longitude),
                            userLocation: userLocation
                        )
                        
                        ReviewsSectionView(reviews: viewModel.location.reviews)
                        
                        if let photos = viewModel.location.photos {
                            CollageView(photos: photos, apiKey: viewModel.apiKey)
                        } else {
                            Text("No photos available")
                        }
                    }
                }
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width > 100 { // Detect swipe gesture
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
            )
            
            VStack(){
                // Custom Divider with line width of 4
                Rectangle()
                    .fill(Color.primary) // Customize the color if needed
                    .frame(height: 0.2) // Set the height to 4 for a thicker line

                // Buttons at the bottom
                HStack(spacing: 16) {
                    Button(action: {
                        print("Fynd a Buddy tapped")
                        // Add your action here
                    }) {
                        Text("Fynd a Buddy")
                            .font(.custom("Lexend-SemiBold", size: 18))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        print("Take Me tapped")
                        // Add your action here
                    }) {
                        Text("Take Me")
                            .font(.custom("Lexend-SemiBold", size: 18))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 37/255, green: 71/255, blue: 116/255, opacity: 1.0))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }

        }
        .navigationBarBackButtonHidden(true)
        .scrollIndicators(.hidden)
        .edgesIgnoringSafeArea(.top)
        .background(LinearGradient(
            gradient: Gradient(colors: [Color.black, Color(red: 37/255, green: 71/255, blue: 116/255, opacity: 0.4)]),
            startPoint: .top,
            endPoint: .bottom
        ))
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                        .padding(10)
                        .background(.ultraThinMaterial) // Add ultra-thin material background
                        .clipShape(Circle()) // Make it circular
                }
            }
        }
    }
}
