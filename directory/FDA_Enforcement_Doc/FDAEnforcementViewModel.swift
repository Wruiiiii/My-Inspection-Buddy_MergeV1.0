import Foundation
import Combine

@MainActor
class FDASearchViewModel: ObservableObject {
    
    @Published var recallNumber: String = ""
    @Published var recallingFirm: String = ""
    @Published var fromDate: Date = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
    @Published var toDate: Date = Date()
    
    @Published var selectedClassification: String = "Any"
    let classificationOptions = ["Any", "Class I", "Class II", "Class III"]
    
    @Published var searchResults: [FDAEnforcementRecord] = []
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func executeSearch() {
        isLoading = true
        errorMessage = nil
        searchResults = []
        
        FDARecallService.shared.searchRecalls(
            firm: recallingFirm,
            number: recallNumber,
            classification: selectedClassification,
            fromDate: fromDate,
            toDate: toDate
        )
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { [weak self] (completion: Subscribers.Completion<APIError>) in
            self?.isLoading = false
            switch completion {
            case .finished:
                break // Success is handled in receiveValue
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
            }
        }, receiveValue: { [weak self] (recalls: [FDAEnforcementRecord]) in
            self?.searchResults = recalls
            if recalls.isEmpty {
                self?.errorMessage = "No results found matching your criteria."
            }
        })
        .store(in: &cancellables)
    }
}

