import Foundation
import Combine

class MaudeAPIService {
    static let shared = MaudeAPIService()
    
    // IMPORTANT: This now points to your single, deployed Render API URL.
    // Replace "your-api-name.onrender.com" with your actual Render service URL.
    private let baseURLString = "https://inspectionbuddy-api.onrender.com/maude"

    // This struct defines the JSON body we will send to our backend.
    struct RequestBody: Codable {
        let deviceName: String
        let fromDate: String
        let toDate: String
    }
    
    // This struct is used to decode the response from the FDA API.
    // It should be defined in your MaudeEvent.swift model file, but is here for context.
    struct MaudeAPIResponse: Codable {
        let results: [MaudeEvent]
    }
    
    func searchMaudeEvents(deviceName: String, fromDate: Date, toDate: Date) -> AnyPublisher<[MaudeEvent], APIError> {
        
        guard let url = URL(string: baseURLString) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Use a single date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let body = RequestBody(
            deviceName: deviceName,
            fromDate: dateFormatter.string(from: fromDate),
            toDate: dateFormatter.string(from: toDate)
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            // If encoding fails, publish an error immediately.
            return Fail(error: APIError.encodingFailed(error)).eraseToAnyPublisher()
        }

        print("Requesting MAUDE URL: \(url)")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            // We expect the FDA's response format, which includes a "results" key.
            .decode(type: MaudeAPIResponse.self, decoder: JSONDecoder())
            .map(\.results)
            .mapError { error -> APIError in
                // Map any error to our centralized APIError type for consistent handling.
                if let decodingError = error as? DecodingError {
                    print("Decoding Error: \(decodingError)")
                    return .decodingFailed(decodingError)
                } else {
                    return .requestFailed(error)
                }
            }
            .eraseToAnyPublisher()
    }
}

