import Foundation

class HistDataFetcher: ObservableObject {
    @Published var documents: [FDADocument] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var currentPage = 1
    @Published var hasMore = true
    @Published var totalResults = 0

    func fetchDocuments(
        query: String,
        docType: String,
        startDate: String,
        endDate: String,
        page: Int = 1,
        limit: Int = 20
    ) {
        isLoading = true
        errorMessage = nil

        let base = "https://historicaldocumentsapi.onrender.com/search"
        var components = URLComponents(string: base)!
        var queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        if !docType.isEmpty {
            queryItems.append(URLQueryItem(name: "title", value: docType))
        }
        if !startDate.isEmpty && !endDate.isEmpty {
            queryItems.append(URLQueryItem(name: "start_date", value: startDate))
            queryItems.append(URLQueryItem(name: "end_date", value: endDate))
        }
        components.queryItems = queryItems

        guard let url = components.url else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
                self.isLoading = false
            }
            return
        }

        print("📡 Fetching URL: \(url.absoluteString)")
        print("📅 Date Range: \(startDate) to \(endDate)")

        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async { self.isLoading = false }

            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received."
                }
                return
            }

            // Debug output
            if let jsonString = String(data: data, encoding: .utf8) {
                print("RAW JSON:\n\(jsonString)")
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(FDAResponse.self, from: data)

                DispatchQueue.main.async {
                    if page == 1 {
                        self.documents = response.results
                    } else {
                        self.documents += response.results
                    }
                    self.totalResults = response.meta.total
                    self.hasMore = (self.documents.count < self.totalResults)
                    self.currentPage = page
                }

            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Decoding error: \(error.localizedDescription)"
                }
            }
        }
        .resume()
    }
}
