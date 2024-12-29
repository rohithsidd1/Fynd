import SwiftUI
import MapKit
import CoreLocation

struct FullScreenMapContainerView: View {
    let destination: CLLocationCoordinate2D
    let userLocation: CLLocationCoordinate2D
    
    @Environment(\.presentationMode) var presentationMode
    @State private var showActionSheet = false // State to show the action sheet
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            FullScreenMapView(destination: destination, userLocation: userLocation)
            
            // Back button
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .padding(10)
                    .background(Color(red: 37/255, green: 71/255, blue: 116/255, opacity: 1.0))
                    .clipShape(Circle())
            }
            .padding(.leading)
            .padding(.top, 50) // Adjust for safe area
            
            // Navigate button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showActionSheet = true // Trigger the action sheet
                    }) {
                        Text("Navigate")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 150)
                            .background(Color(red: 37/255, green: 71/255, blue: 136/255, opacity: 1.0))
                            .cornerRadius(50)
                            .padding(.bottom)
                    }
                    .padding()
                    .actionSheet(isPresented: $showActionSheet) {
                        ActionSheet(
                            title: Text("Open in Maps"),
                            message: Text("Choose an app for navigation"),
                            buttons: [
                                .default(Text("Google Maps")) {
                                    openInGoogleMaps()
                                },
                                .default(Text("Apple Maps")) {
                                    openInAppleMaps()
                                },
                                .cancel()
                            ]
                        )
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    // Open in Google Maps
    private func openInGoogleMaps() {
        let urlString = "comgooglemaps://?daddr=\(destination.latitude),\(destination.longitude)&directionsmode=driving"
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        } else {
            // If Google Maps is not installed, show alert
            if let webURL = URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(destination.latitude),\(destination.longitude)&travelmode=driving") {
                UIApplication.shared.open(webURL, options: [:])
            }
        }
    }
    
    // Open in Apple Maps
    private func openInAppleMaps() {
        let destinationPlacemark = MKPlacemark(coordinate: destination)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        destinationMapItem.name = "Destination"
        
        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        destinationMapItem.openInMaps(launchOptions: options)
    }
}
