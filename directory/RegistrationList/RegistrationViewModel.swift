//
//  RegistrationViewModel.swift
//  LicensingDatabaseApp
//
//  Created by Tanay Doppalapudi on 7/8/25.
//  Updated by ChatGPT on 7/11/25.
//

import Foundation

@MainActor
class RegistrationViewModel: ObservableObject {
    
    // MARK: – Published state
    @Published var registrations: [FDARegistration] = []
    @Published var isLoading       = false
    @Published var error: String?  = nil
    @Published var didTriggerSearch = false
    @Published var totalCount      = 0        // ← total from meta.results.total
    
    // MARK: – Private
    private let service      = FDAService()
    private var currentQuery = ""
    private var currentSkip  = 0
    private let limit        = 20
    private var isFetchingMore = false
    
    // MARK: – Public API  ------------------------------
    
    /// Start a brand-new search (or default “match-all”).
    func search(_ query: String) async {
        didTriggerSearch = true
        // Default to match-all on the correct JSON field
        currentQuery = query.isEmpty
            ? "registration_detail.registration_number:[* TO *]"
            : query

        currentSkip = 0
        isLoading = true
        error = nil

        // Debug: print the outgoing query parameters
        print("Searching with query: \(currentQuery), skip: \(currentSkip), limit: \(limit)")

        do {
            let (results, total) = try await service.fetchRegistrations(
                query: currentQuery,
                limit: limit,
                skip: currentSkip
            )
            totalCount = total
            let sortedResults = sortUnknownLast(results)
            registrations = sortedResults

            // Handle empty-but-no-error responses
            if results.isEmpty {
                self.error = "No results found for your search."
            }
        } catch {
            let nsError = error as NSError
            if nsError.localizedDescription == "No matches found!" {
                // No matches is not a crash: clear out and show message
                self.registrations = []
                self.totalCount = 0
                if didTriggerSearch {
                    self.error = "No results found for your search."
                }
            } else {
                self.error = nsError.localizedDescription
            }
        }

        isLoading = false
    }
    
    /// Trigger load-more when user scrolls near the end.
    func loadMoreIfNeeded(currentItem: FDARegistration?) async {
        guard let currentItem = currentItem else { return }
        let thresholdIndex = registrations.index(registrations.endIndex, offsetBy: -5)
        guard registrations.firstIndex(where: { $0.id == currentItem.id }) == thresholdIndex else { return }
        
        await loadMore()
    }
    
    // MARK: – Private helpers  -------------------------
    
    private func loadMore() async {
        guard !isFetchingMore,
              registrations.count < totalCount      // stop when all loaded
        else { return }
        
        isFetchingMore = true
        currentSkip += limit   // fixed skip increment
        
        do {
            let (moreResults, _) = try await service.fetchRegistrations(
                query: currentQuery,
                limit: limit,
                skip: currentSkip
            )
            registrations.append(contentsOf: moreResults)
            registrations = sortUnknownLast(registrations)
        } catch {
            print("Failed to load more: \(error)")
        }
        
        isFetchingMore = false
    }
    
    /// Sort so entries lacking a proprietary name appear last.
    private func sortUnknownLast(_ list: [FDARegistration]) -> [FDARegistration] {
        list.sorted {
            let a = $0.proprietaryName?.first ?? "zzz"
            let b = $1.proprietaryName?.first ?? "zzz"
            return a.localizedCaseInsensitiveCompare(b) == .orderedAscending
        }
    }
    
    /// Reset all state to initial values.
    func reset() {
        registrations = []
        totalCount = 0
        error = nil
        didTriggerSearch = false
        currentQuery = ""
        currentSkip = 0
    }
}
