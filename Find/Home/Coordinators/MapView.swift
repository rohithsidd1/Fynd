import SwiftUI
import MapKit

struct FullScreenMapView: UIViewRepresentable {
    let destination: CLLocationCoordinate2D
    let userLocation: CLLocationCoordinate2D

    @Environment(\.presentationMode) var presentationMode

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        mapView.mapType = .hybrid

        // Add source and destination annotations
        let sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.coordinate = userLocation
        sourceAnnotation.title = "Your Location"

        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.coordinate = destination
        destinationAnnotation.title = "Destination"

        mapView.addAnnotations([sourceAnnotation, destinationAnnotation])

        // Calculate and show the route
        let sourcePlacemark = MKPlacemark(coordinate: userLocation)
        let destinationPlacemark = MKPlacemark(coordinate: destination)

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: sourcePlacemark)
        request.destination = MKMapItem(placemark: destinationPlacemark)
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let error = error {
                print("Error calculating directions: \(error.localizedDescription)")
                return
            }

            if let route = response?.routes.first {
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(
                    route.polyline.boundingMapRect,
                    edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50),
                    animated: true
                )
            }
        }

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                
                // Gradient-like color: Start with a semi-transparent blue
                renderer.strokeColor = UIColor.systemBlue.withAlphaComponent(0.8)
                
                // Set the line width to make it more prominent
                renderer.lineWidth = 5
                
                // Add line cap for smoother edges
                renderer.lineCap = .round
                
                // Add line join for smoother corners
                renderer.lineJoin = .round
                
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}
