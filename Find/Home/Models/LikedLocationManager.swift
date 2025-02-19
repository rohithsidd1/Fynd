import SwiftUI
import MapKit

class LikedLocationManager {
    static func getLikedLocations() -> [String] {
        // Fetch liked location IDs from UserDefaults or a database
        return UserDefaults.standard.stringArray(forKey: "likedLocations") ?? []
    }
    
    static func addLikedLocation(_ id: String) {
        var likedLocations = getLikedLocations()
        likedLocations.append(id)
        UserDefaults.standard.set(likedLocations, forKey: "likedLocations")
    }
    
    static func removeLikedLocation(_ id: String) {
        var likedLocations = getLikedLocations()
        likedLocations.removeAll { $0 == id }
        UserDefaults.standard.set(likedLocations, forKey: "likedLocations")
    }
}

