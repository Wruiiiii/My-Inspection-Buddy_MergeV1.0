//
//  Untitled.swift
//  My Inspection Buddy_MergeV1.0
//
//  Created by Rae Wang on 7/10/25.
//

import Foundation
import Combine

@MainActor
class WarningLetterViewModel: ObservableObject {
    @Published var firmName: String = ""
    @Published var results: [WarningLetter] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    

    private let apiURL = URL(string:"https://inspectionbuddy-api.onrender.com/warning_letters")!

    func searchWarningLetters() {
        guard !firmName.trimmingCharacters(in: .whitespaces).isEmpty else {
            self.errorMessage = "Please enter a firm name."
            return
        }
        
        isLoading = true
        errorMessage = nil
        results = []

        Task {
            do {
                var request = URLRequest(url: apiURL)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let body = ["firmName": firmName]
                request.httpBody = try JSONEncoder().encode(body)

                let (data, _) = try await URLSession.shared.data(for: request)
                
                let decodedResults = try JSONDecoder().decode([WarningLetter].self, from: data)
                self.results = decodedResults
                
                if decodedResults.isEmpty {
                    self.errorMessage = "No warning letters found for the provided firm."
                }
                
            } catch {
                self.errorMessage = "Failed to fetch data: \(error.localizedDescription)"
                print("Error fetching data: \(error)")
            }
            
            isLoading = false
        }
    }
}
