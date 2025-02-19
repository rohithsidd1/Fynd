import UIKit
import SwiftUI
import MapKit

struct Location: Identifiable, Decodable {
    let id: String
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let imageUrl: String?
    let photos: [Photo]?
    let reviews: [Review]?
    let viewport: Viewport?
    let rating: Double?
    let openingHours: OpeningHours?
    let editorialSummary: EditorialSummary?
    let formattedPhoneNumber: String?
    let formattedAddress: String?
    let website: String?

    // Add a convenience initializer with default values
    init(
        id: String,
        name: String,
        address: String,
        latitude: Double,
        longitude: Double,
        imageUrl: String? = nil,
        photos: [Photo]? = nil,
        reviews: [Review]? = nil,
        viewport: Viewport? = nil,
        rating: Double? = nil,
        openingHours: OpeningHours? = nil,
        editorialSummary: EditorialSummary? = nil,
        formattedPhoneNumber: String? = nil,
        formattedAddress: String? = nil,
        website: String? = nil
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.imageUrl = imageUrl
        self.photos = photos
        self.reviews = reviews
        self.viewport = viewport
        self.rating = rating
        self.openingHours = openingHours
        self.editorialSummary = editorialSummary
        self.formattedPhoneNumber = formattedPhoneNumber
        self.formattedAddress = formattedAddress
        self.website = website
    }

    enum CodingKeys: String, CodingKey {
        case id = "place_id"
        case name
        case address = "vicinity"
        case geometry
        case photos
        case viewport
        case rating
        case openingHours = "opening_hours" // Add key for opening_hours
        case editorialSummary = "editorial_summary" // Key for "About"
        case formattedPhoneNumber = "formatted_phone_number" // Key for phone number
        case formattedAddress = "formatted_address" // Key for address
        case website // Key for website
        case reviews // Key for reviews
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.address = try container.decode(String.self, forKey: .address)

        // Decode latitude and longitude
        let geometry = try container.decode(Geometry.self, forKey: .geometry)
        self.latitude = geometry.location.lat
        self.longitude = geometry.location.lng

        // Decode photos
        self.photos = try? container.decode([Photo].self, forKey: .photos)

        // Set the first photo as image URL
        self.imageUrl = photos?.first?.photoReference

        // Decode viewport
        self.viewport = try? container.decode(Viewport.self, forKey: .viewport)

        // Decode rating
        self.rating = try? container.decode(Double.self, forKey: .rating)

        // Decode opening hours
        self.openingHours = try? container.decode(OpeningHours.self, forKey: .openingHours)

        // Decode editorial summary (About)
        self.editorialSummary = try? container.decode(EditorialSummary.self, forKey: .editorialSummary)

        // Decode phone number
        self.formattedPhoneNumber = try? container.decode(String.self, forKey: .formattedPhoneNumber)

        // Decode formatted address
        self.formattedAddress = try? container.decode(String.self, forKey: .formattedAddress)

        // Decode website
        self.website = try? container.decode(String.self, forKey: .website)

        // Decode reviews
        self.reviews = try? container.decode([Review].self, forKey: .reviews)
    }
}

struct Review: Decodable {
    let authorName: String? // Reviewer name
    let profilePhotoUrl: String? // Profile picture URL
    let rating: Double? // Rating given by the reviewer
    let text: String? // Review content
    let timeDescription: String? // Relative time description of the review

    enum CodingKeys: String, CodingKey {
        case authorName = "author_name"
        case profilePhotoUrl = "profile_photo_url"
        case rating
        case text
        case timeDescription = "relative_time_description"
    }
}

struct EditorialSummary: Decodable {
    let overview: String?
}


// Model for opening hours
struct OpeningHours: Decodable {
    let openNow: Bool?

    enum CodingKeys: String, CodingKey {
        case openNow = "open_now"
    }
}

// Model for geometry
struct Geometry: Decodable {
    let location: LocationCoordinates
    let viewport: Viewport
}

// Model for latitude and longitude
struct LocationCoordinates: Decodable {
    let lat: Double
    let lng: Double
}

// Viewport model to handle viewport field
struct Viewport: Decodable {
    let northeast: LocationCoordinates
    let southwest: LocationCoordinates
}

// Model to handle photos in the location (for Google Places API)
struct Photo: Decodable, Identifiable {
    let id = UUID()
    let photoReference: String

    enum CodingKeys: String, CodingKey {
        case photoReference = "photo_reference"
    }
}

// Response model for the Places API
struct LocationResponse: Decodable {
    let results: [Location]
}

struct LocationResponseWithToken: Decodable {
    let results: [Location]
    let nextPageToken: String?

    enum CodingKeys: String, CodingKey {
        case results
        case nextPageToken = "next_page_token"
    }
}


struct LocationDetailsResponse: Decodable {
    let result: Location
}

struct LocationAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
