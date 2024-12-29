import SwiftUI
import CoreHaptics

struct SearchSortScrollView: View {
    @Binding var selectedLocationType: LocationFetcher.LocationType
    @Binding var selectedRadius: Int
    let locationTypes: [LocationFetcher.LocationType]
    let locationManager: LocationManager
    let locationFetcher: LocationFetcher
    var isTabView: Bool // Controls if the view behaves like tabs or not

    @State private var showMoreOptions = false // State to show/hide the sheet
    @Namespace private var animationNamespace // Namespace for matched geometry effect

    // Displayed options at the top
    private var topOptions: [LocationFetcher.LocationType] {
        [.restaurant, .shop, .hotel, .hospital, .gasStation, .pub, .viewpoints, .metros, .bus, .railway]
    }

    // Remaining options for the sheet
    private var remainingOptions: [LocationFetcher.LocationType] {
        locationTypes.filter { !topOptions.contains($0) }
    }

    // Icon and Title Mapping
    private func iconAndTitle(for locationType: LocationFetcher.LocationType) -> (icon: String, filledIcon: String, title: String) {
        switch locationType {
        case .restaurant:
            return ("fork.knife", "fork.knife", "Dine in")
        case .shop:
            return ("bag", "bag.fill", "Shopping")
        case .hotel:
            return ("bed.double", "bed.double.fill", "Hotels")
        case .hospital:
            return ("cross", "cross.fill", "Hospitals")
        case .gasStation:
            return ("fuelpump", "fuelpump.fill", "Petrol")
        case .pub:
            return ("wineglass", "wineglass.fill", "Pubs")
        case .viewpoints:
            return ("mountain.2", "mountain.2.fill", "Views")
        case .metros:
            return ("tram", "tram.fill", "Metro")
        case .bus:
            return ("bus", "bus.fill", "Bus")
        case .railway:
            return ("train.side.front.car", "train.side.front.car", "Railway")
        default:
            return ("circle", "circle.fill", locationType.rawValue.capitalized)
        }
    }

    var body: some View {
        ZStack {
            HStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // Display the top options
                        ForEach(topOptions, id: \.self) { locationType in
                            let (icon, filledIcon, title) = iconAndTitle(for: locationType)

                            Group {
                                if isTabView {
                                    HStack(spacing: 4) {
                                        Image(systemName: selectedLocationType == locationType ? filledIcon : icon)
                                            .font(.system(size: 16))
                                            .foregroundColor(selectedLocationType == locationType ? .white : .primary)
                                            .matchedGeometryEffect(id: locationType.rawValue + "icon", in: animationNamespace)

                                        Text(title)
                                            .font(.custom("Lexend-Regular", size: 12))
                                            .foregroundColor(selectedLocationType == locationType ? .white : .primary)
                                            .matchedGeometryEffect(id: locationType.rawValue + "text", in: animationNamespace)
                                    }
                                    .padding(8)
                                    .frame(width: .infinity) // Flexible width for tab view
                                    .background(selectedLocationType == locationType ? Color(red: 37 / 255, green: 71 / 255, blue: 116 / 255, opacity: 1.0) : Color.gray.opacity(0.3))
                                    .cornerRadius(8)
                                    .onTapGesture {
                                        handleOptionSelection(locationType)
                                    }
                                } else {
                                    VStack(spacing: 4) {
                                        Image(systemName: selectedLocationType == locationType ? filledIcon : icon)
                                            .font(.system(size: selectedLocationType == locationType ? 28 : 20))
                                            .foregroundColor(selectedLocationType == locationType ? .white : .primary)
                                            .matchedGeometryEffect(id: locationType.rawValue + "icon", in: animationNamespace)

                                        Text(title)
                                            .font(.custom("Lexend-Regular", size: selectedLocationType == locationType ? 14 : 10))
                                            .foregroundColor(selectedLocationType == locationType ? .white : .primary)
                                            .matchedGeometryEffect(id: locationType.rawValue + "text", in: animationNamespace)
                                    }
                                    .padding(selectedLocationType == locationType ? 12 : 8)
                                    .frame(width: selectedLocationType == locationType ? 88 : 68, height: selectedLocationType == locationType ? 80 : 60)
                                    .background(selectedLocationType == locationType ? Color(red: 37 / 255, green: 71 / 255, blue: 116 / 255, opacity: 1.0) : Color.gray.opacity(0.3))
                                    .cornerRadius(8)
                                    .onTapGesture {
                                        handleOptionSelection(locationType)
                                    }
                                }
                            }
                        }

                        // "More" button to show the remaining options
                        Button(action: {
                            generateHapticFeedback()
                            showMoreOptions = true
                        }) {
                            if isTabView {
                                HStack(spacing: 4) {
                                    Image(systemName: "ellipsis.circle")
                                        .font(.system(size: 16))
                                        .foregroundColor(.black)

                                    Text("More")
                                        .font(.custom("Lexend-Regular", size: 12))
                                        .foregroundColor(.black)
                                }
                                .padding(8)
                                .frame(width: .infinity)
                                .background(Color.white)
                                .cornerRadius(8)
                            } else {
                                VStack(spacing: 6) {
                                    Image(systemName: "ellipsis.circle")
                                        .font(.system(size: 20))
                                        .foregroundColor(.black)

                                    Text("More")
                                        .font(.custom("Lexend-Regular", size: 10))
                                        .foregroundColor(.black)
                                }
                                .padding(12)
                                .frame(width: 68, height: 60)
                                .background(Color.white)
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isTabView) // Smooth animation for transitions
        }
        .sheet(isPresented: $showMoreOptions) {
            MoreOptionsSheetView(
                remainingOptions: remainingOptions,
                selectedLocationType: $selectedLocationType,
                locationFetcher: locationFetcher,
                locationManager: locationManager,
                selectedRadius: $selectedRadius,
                showMoreOptions: $showMoreOptions
            )
        }
    }

    private func generateHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred()
    }

    private func handleOptionSelection(_ locationType: LocationFetcher.LocationType) {
        generateHapticFeedback()
        selectedLocationType = locationType
        locationFetcher.fetchLocations(
            latitude: locationManager.userLocation?.latitude ?? 0,
            longitude: locationManager.userLocation?.longitude ?? 0,
            radius: selectedRadius,
            type: selectedLocationType
        )
    }
}

import SwiftUI
import CoreHaptics

struct MoreOptionsSheetView: View {
    let remainingOptions: [LocationFetcher.LocationType]
    @Binding var selectedLocationType: LocationFetcher.LocationType
    let locationFetcher: LocationFetcher
    let locationManager: LocationManager
    @Binding var selectedRadius: Int
    @Binding var showMoreOptions: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text("Fynd your Category!")
                .font(.custom("Lexend-Medium", size: 28))
                .foregroundColor(.white)
                .padding(.horizontal)
                .multilineTextAlignment(.leading)
                .padding(.top, 32)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: Array(repeating: GridItem(.flexible(), spacing: 48), count: 4), spacing: 10) {
                    ForEach(remainingOptions, id: \.self) { locationType in
                        Button(action: {
                            generateHapticFeedback() // Add haptic feedback
                            selectedLocationType = locationType
                            locationFetcher.fetchLocations(
                                latitude: locationManager.userLocation?.latitude ?? 0,
                                longitude: locationManager.userLocation?.longitude ?? 0,
                                radius: selectedRadius,
                                type: selectedLocationType
                            )
                            showMoreOptions = false // Dismiss the sheet
                        }) {
                            Text(locationType.rawValue.capitalized)
                                .font(.custom("Lexend-Regular", size: 14))
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .background(.ultraThinMaterial)
                                .foregroundColor(.primary)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }
        }
        .presentationDetents([.fraction(0.4)])
    }

    // MARK: - Haptic Feedback Generator
    private func generateHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred()
    }
}
