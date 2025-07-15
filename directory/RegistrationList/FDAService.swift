//
//  FDAService.swift
//  LicensingDatabaseApp
//
//  Created by Tanay Doppalapudi on 7/8/25.
//  Updated by ChatGPT on 7/11/25.
//

import Foundation

struct APIErrorResponse: Decodable {
    let error: APIError

    struct APIError: Decodable {
        let code: String
        let message: String
    }
}

class FDAService {
    private let baseURL = "https://api.fda.gov/device/registrationlisting.json"
    
    /// Fetches a page of FDA registrations and returns `(results, totalCount)`.
    func fetchRegistrations(
        query rawQuery: String,
        limit: Int = 25,
        skip: Int = 0
    ) async throws -> ([FDARegistration], Int) {
        
        // Fallback to match-all if the query is empty
        // 👉 Changed registration.registration_number to registration_detail.registration_number
        let safeQuery = rawQuery.isEmpty
            ? "registration_detail.registration_number:[* TO *]"
            : rawQuery
        
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "search", value: safeQuery),
            URLQueryItem(name: "limit",  value: "\(limit)"),
            URLQueryItem(name: "skip",   value: "\(skip)")
        ]
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        print("📡 Fetching from: \(url)")
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("🔎 Status Code: \(httpResponse.statusCode)")
        }
        
        do {
            // Check if response is an error structure instead of the expected response
            if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                print("⚠️ API returned error: \(apiError.error.message)")
                throw NSError(domain: "FDAService",
                              code: 404,
                              userInfo: [NSLocalizedDescriptionKey: apiError.error.message])
            }
            let decoded = try JSONDecoder().decode(FDAResponses.self, from: data)
            return (decoded.results, decoded.meta.results.total)
        } catch {
            if let rawBody = String(data: data, encoding: .utf8) {
                print("🔻 Raw Response Body: \(rawBody)")
            }
            print("❌ Decoding error: \(error)")
            throw error
        }
    }
}
