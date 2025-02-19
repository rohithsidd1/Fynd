import SwiftUI

class UserActivityService {
    private let baseURL = "https://your-backend-server.com/api"
    
    /// Save user preference for a specific location.
    func saveUserPreference(location: Location, completion: @escaping (Bool) -> Void) {
        let endpoint = "\(baseURL)/savePreference"
        let preference = ["locationId": location.id, "name": location.name]
        performPostRequest(endpoint: endpoint, body: preference, completion: completion)
    }
    
    /// Log user activity for analytics.
    func logUserActivity(activity: [String: Any], completion: @escaping (Bool) -> Void) {
        let endpoint = "\(baseURL)/logActivity"
        performPostRequest(endpoint: endpoint, body: activity, completion: completion)
    }
    
    /// Send feedback about a location.
    func sendFeedback(locationId: String, feedback: String, completion: @escaping (Bool) -> Void) {
        let endpoint = "\(baseURL)/feedback"
        let feedbackData = ["locationId": locationId, "feedback": feedback]
        performPostRequest(endpoint: endpoint, body: feedbackData, completion: completion)
    }
    
    func updateUserPreference(location: Location, newName: String, completion: @escaping (Bool) -> Void) {
        let endpoint = "\(baseURL)/updatePreference/\(location.id)"
        let updatedData = ["name": newName]
        performPutRequest(endpoint: endpoint, body: updatedData, completion: completion)
    }

    func updateFeedback(locationId: String, newFeedback: String, completion: @escaping (Bool) -> Void) {
        let endpoint = "\(baseURL)/updateFeedback/\(locationId)"
        let updatedFeedbackData = ["feedback": newFeedback]
        performPutRequest(endpoint: endpoint, body: updatedFeedbackData, completion: completion)
    }

    func updateActivityLog(logId: String, updatedData: [String: Any], completion: @escaping (Bool) -> Void) {
        let endpoint = "\(baseURL)/updateActivity/\(logId)"
        performPutRequest(endpoint: endpoint, body: updatedData, completion: completion)
    }

    /// Generic method to perform a POST request.
    private func performPostRequest(endpoint: String, body: [String: Any], completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: endpoint) else {
            print("Invalid URL: \(endpoint)")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let requestBody = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = requestBody
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error in POST request: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Unexpected response: \(String(describing: response))")
                completion(false)
                return
            }
            
            completion(true)
        }.resume()
    }
    
    private func performPutRequest(endpoint: String, body: [String: Any], completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: endpoint) else {
            print("Invalid URL: \(endpoint)")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let requestBody = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = requestBody
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error in PUT request: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Unexpected response: \(String(describing: response))")
                completion(false)
                return
            }
            
            completion(true)
        }.resume()
    }

}
