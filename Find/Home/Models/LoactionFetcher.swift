import SwiftUI
import MapKit

class LocationFetcher: ObservableObject {
    @Published var locations: [Location] = []
    private var nextPageToken: String? = nil // Store next_page_token
    private var fetchedLocationIDs: Set<String> = [] // Track unique IDs
    private var cache: [String: Location] = [:] // Cache for locations by ID
    @Published var userLocationManuallySet: CLLocationCoordinate2D? // Manually updated location

    let apiKey = ""
    
    enum LocationType: String {
        case restaurant = "Restaurants and dinein"
        case shop = "Shopping"
        case hotel = "Hotels"
        case park = "Park"
        case museum = "Museums"
        case library = "Library"
        case mall = "Malls"
        case cafe = "Cafe"
        case hospital = "Hospitals"
        case pharmacy = "Pharmacy"
        case theater = "Movie Theaters"
        case stadium = "Stadiums"
        case school = "Schools"
        case university = "Universities"
        case zoo = "Zoo"
        case amusementPark = "Amusement Park"
        case culturalInstitution = "Art Gallery"
        case gasStation = "Gas Stations"
        case atm = "Atm"
        case postOffice = "Post Office"
        case bank = "Bank"
        case church = "Church"
        case mosque = "Mosque"
        case temple = "Temples"
        case clinic = "Clinic"
        case pub = "Pubs"
        case brewery = "Brewery"
        case bars = "Bars"
        case gyms = "Gyms"
        case hostels = "Hostels"
        case pg = "PG"
        case livemusic = "Live Music"
        case supermarts = "Super Markets"
        case electronics = "Electronics"
        case rentals = "Bike and car Rentals"
        case martialarts = "martial arts"
        case viewpoints = "View Points and popular places"
        case metros = "Metro Stations"
        case bus = "Bus stands"
        case railway = "Railway Stations"
    }
    
    func updateUserLocationManually(latitude: Double, longitude: Double, radius: Int, type: LocationFetcher.LocationType) {
        self.userLocationManuallySet = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        fetchLocations(latitude: latitude, longitude: longitude, radius: radius, type: type)
    }


    func fetchLocations(latitude: Double, longitude: Double, radius: Int, type: LocationType, isNextPage: Bool = false) {
        var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=\(radius)&type=\(type.rawValue)&keyword=\(type.rawValue)&key=\(apiKey)"
        
        if !isNextPage {
            DispatchQueue.main.async {
                self.locations = [] // Clear previous locations
                self.fetchedLocationIDs = [] // Clear previous fetched IDs
                self.nextPageToken = nil // Reset nextPageToken
            }
        }
        
        if isNextPage, let nextPageToken = nextPageToken {
            urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=\(nextPageToken)&key=\(apiKey)"
        }
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    print("Error fetching data: \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    print("No data received")
                }
                return
            }
            
            DispatchQueue.global(qos: .background).async {
                let decoder = JSONDecoder()
                do {
                    let decodedData = try decoder.decode(LocationResponseWithToken.self, from: data)
                    DispatchQueue.main.async {
                        let uniqueResults = decodedData.results.filter { location in
                            !self.fetchedLocationIDs.contains(location.id)
                        }
                        
                        self.fetchedLocationIDs.formUnion(uniqueResults.map { $0.id })
                        
                        // Cache new locations
                        uniqueResults.forEach { location in
                            self.cache[location.id] = location
                        }
                        
                        if !isNextPage {
                            self.locations = uniqueResults
                        } else {
                            self.locations.append(contentsOf: uniqueResults)
                        }
                        
                        self.nextPageToken = decodedData.nextPageToken
                    }
                } catch {
                    DispatchQueue.main.async {
                        print("Error decoding data: \(error.localizedDescription)")
                    }
                }
            }
        }.resume()
    }
    
    func getLocationById(_ id: String, completion: @escaping (Location?) -> Void) {
        // Check if the location is already cached
        if let cachedLocation = cache[id] {
            completion(cachedLocation)
            return
        }
        
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(id)&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            if let error = error {
                print("Error fetching location: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            DispatchQueue.global(qos: .background).async {
                let decoder = JSONDecoder()
                do {
                    let decodedData = try decoder.decode(LocationDetailsResponse.self, from: data)
                    let location = decodedData.result
                    
                    DispatchQueue.main.async {
                        // Cache the fetched location
                        self.cache[location.id] = location
                        completion(location)
                    }
                } catch {
                    print("Error decoding location data: \(error)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
        }.resume()
    }
}
