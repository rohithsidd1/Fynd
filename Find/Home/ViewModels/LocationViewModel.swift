import SwiftUI

class LocationCardViewModel: ObservableObject {
    @Published var isLiked: Bool
    @Published var about: String = "Loading..."
    @Published var details: String = "Loading details..."
    @Published var photos: [String] = [] // Stores photo references
    @Published var posts: [Review] = []  // Stores user reviews or posts
    var location: Location

    private static var cache: [String: Location] = [:] // Static cache for location details

    let apiKey = "AIzaSyAELiwUuzrOY2aJmxODxdIyTfa5MCJ5eeY"

    init(location: Location) {
        self.location = location
        let likedLocations = LikedLocationManager.getLikedLocations()
        self.isLiked = likedLocations.contains(location.id)
        fetchDetails()
    }

    private func fetchDetails() {
        // Check cache for existing details
        if let cachedDetails = Self.cache[location.id] {
            updateUI(with: cachedDetails)
            return
        }

        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(location.id)&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.about = "No information available"
                self.details = "No details available"
            }
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                DispatchQueue.main.async {
                    self.about = "Error fetching details: \(error.localizedDescription)"
                    self.details = "Error fetching details: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.about = "No data received"
                    self.details = "No data received"
                }
                return
            }

            DispatchQueue.global(qos: .background).async {
                let decoder = JSONDecoder()
                do {
                    let decodedData = try decoder.decode(LocationDetailsResponse.self, from: data)
                    DispatchQueue.main.async {
                        // Cache the result
                        Self.cache[self.location.id] = decodedData.result
                        
                        // Update UI
                        self.updateUI(with: decodedData.result)
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.about = "Error decoding details: \(error.localizedDescription)"
                        self.details = "Error decoding details: \(error.localizedDescription)"
                    }
                }
            }
        }.resume()
    }

    private func updateUI(with details: Location) {
        self.location = details

        // Parse "About" section
        if let overview = details.editorialSummary?.overview {
            self.about = overview
        } else {
            self.about = "No information available"
        }

        // Parse other "Details"
        var detailInfo = ""
        if let phone = details.formattedPhoneNumber {
            detailInfo += "Phone: \(phone)\n"
        }
        if let website = details.website {
            detailInfo += "Website: \(website)\n"
        }
        if let address = details.formattedAddress {
            detailInfo += "Address: \(address)\n"
        }
        self.details = detailInfo.isEmpty ? "No details available" : detailInfo.trimmingCharacters(in: .whitespacesAndNewlines)

        // Parse Photos
        if let photos = details.photos {
            self.photos = photos.compactMap { $0.photoReference }
        }

        // Parse Reviews (Posts)
        if let reviews = details.reviews {
            self.posts = reviews
        }
    }

    func toggleLike() {
        if isLiked {
            LikedLocationManager.removeLikedLocation(location.id)
        } else {
            LikedLocationManager.addLikedLocation(location.id)
        }
        isLiked.toggle()
    }
    
    func parseDetail(from details: String, for key: String) -> String? {
        let lines = details.split(separator: "\n")
        for line in lines {
            if line.starts(with: key) {
                return line.replacingOccurrences(of: "\(key): ", with: "")
            }
        }
        return nil
    }

}
