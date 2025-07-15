import SwiftUI
import Foundation

struct HistContentView: View {
    @StateObject private var fetcher = HistDataFetcher()
    @State private var query = ""
    @State private var selectedTitle = "All"
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var showResults = false
    @State private var filterByDate = true
    @State private var filtersExpanded = true
    @State private var sortAscending: Bool = true

    private let documentTypes = ["All", "Press Release", "Talk"]

    private let docTypeMapping: [String: String] = [
        "Press Release": "pr",
        "Talk": "talk"
    ]

    private var years: [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array(1900...currentYear).reversed()
    }

    private var sortedDocuments: [FDADocument] {
        fetcher.documents.sorted {
            sortAscending
                ? ($0.year ?? 0) < ($1.year ?? 0)
                : ($0.year ?? 0) > ($1.year ?? 0)
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 8) {
                DisclosureGroup("Filters", isExpanded: $filtersExpanded) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Search documents...", text: $query)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }

                        VStack(alignment: .leading) {
                            Text("Document Type")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Picker("Document Type", selection: $selectedTitle) {
                                ForEach(documentTypes, id: \.self) { type in
                                    Text(type)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        .padding(.horizontal, 8)

                        Toggle("Filter by Year", isOn: $filterByDate)
                            .padding(.bottom, 4)

                        if filterByDate {
                            Text("Year: \(String(selectedYear))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Slider(
                                value: Binding(
                                    get: { Double(selectedYear) },
                                    set: { selectedYear = Int($0) }
                                ),
                                in: Double(years.last ?? 1900)...Double(years.first ?? selectedYear),
                                step: 1
                            )
                        }
                    }
                    .padding(.horizontal, 8)
                }
                .padding(.horizontal, 8)
                .animation(.default, value: filtersExpanded)
                .onChange(of: showResults) { newValue in
                    if newValue {
                        filtersExpanded = false
                    }
                }

                Button(action: {
                    fetcher.errorMessage = nil
                    fetcher.currentPage = 1
                    let titleParam = selectedTitle == "All" ? "" : (docTypeMapping[selectedTitle] ?? "")
                    fetcher.fetchDocuments(
                        query: query,
                        docType: titleParam,
                        startDate: filterByDate ? "\(selectedYear)-01-01" : "",
                        endDate: filterByDate ? "\(selectedYear)-12-31" : "",
                        page: 1
                    )
                    showResults = true
                }) {
                    HStack {
                        Image(systemName: "magnifyingglass.circle.fill")
                        Text("Search").bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal, 8)
                }
                .disabled(fetcher.isLoading)

                Picker("Sort by Year", selection: $sortAscending) {
                    Text("Oldest First").tag(true)
                    Text("Newest First").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 8)

                if showResults && !fetcher.isLoading && fetcher.errorMessage == nil {
                    Text("Total Results: \(fetcher.totalResults)")
                        .font(.subheadline)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if fetcher.isLoading && fetcher.documents.isEmpty {
                    ProgressView("Loading...").padding()
                } else if let error = fetcher.errorMessage {
                    VStack {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                        Button("Retry") {
                            let titleParam = selectedTitle == "All" ? "" : (docTypeMapping[selectedTitle] ?? "")
                            fetcher.fetchDocuments(
                                query: query,
                                docType: titleParam,
                                startDate: filterByDate ? "\(selectedYear)-01-01" : "",
                                endDate: filterByDate ? "\(selectedYear)-12-31" : "",
                                page: fetcher.currentPage
                            )
                        }
                        .padding(.bottom)
                    }
                } else if showResults && fetcher.documents.isEmpty {
                    Text("No documents found.")
                        .foregroundColor(.gray)
                        .padding()
                } else if showResults {
                    List(sortedDocuments) { doc in
                        NavigationLink(destination: DocumentDetailView(document: doc)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(doc.displayType)
                                    .font(.headline)
                                Text("Year: \(String (doc.year ?? 0)) – \(doc.department)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    if fetcher.hasMore {
                        Button(action: {
                            let titleParam = selectedTitle == "All" ? "" : (docTypeMapping[selectedTitle] ?? "")
                            fetcher.fetchDocuments(
                                query: query,
                                docType: titleParam,
                                startDate: filterByDate ? "\(selectedYear)-01-01" : "",
                                endDate: filterByDate ? "\(selectedYear)-12-31" : "",
                                page: fetcher.currentPage + 1
                            )
                        }) {
                            Text(fetcher.isLoading ? "Loading..." : "Load More")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(fetcher.isLoading ? Color.gray : Color.blue.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .padding(.horizontal)
                        }
                        .disabled(fetcher.isLoading)
                    }
                }

                Spacer()
            }
            .navigationTitle("FDA Historical Docs")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    filtersExpanded.toggle()
                } label: {
                    Image(systemName: filtersExpanded
                          ? "line.horizontal.3.decrease.circle.fill"
                          : "line.horizontal.3.decrease.circle")
                }
            }
        }
    }
}
