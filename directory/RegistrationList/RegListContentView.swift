//
//  ContentView.swift
//  LicensingDatabaseApp
//
//  Created by Tanay Doppalapudi on 7/8/25.
//  Updated by ChatGPT on 7/11/25.
//

import SwiftUI

struct RegListContentView: View {
    // View-model
    @StateObject private var viewModel = RegistrationViewModel()
    
    // Filters
    @State private var filterByRegistrationNumber = ""
    @State private var filterByState              = "CA"   // Default to California (operator)
    @State private var filterByCountry            = ""
    @State private var filterByCompany            = ""    // Registration name
    @State private var filterByFEI                = ""
    @State private var filterByDeviceName         = ""
    @State private var filterByUSAgentName        = ""
    @State private var filterByCreationDate       = ""    // YYYY format
    @State private var filterByExpiryYear         = ""    // Reg expiry year
    @State private var filtersExpanded            = true
    
    var body: some View {
        NavigationView {
            VStack {
                // Toggle button for collapsing/expanding filters
                HStack {
                    Button(action: { filtersExpanded.toggle() }) {
                        Label(
                            filtersExpanded ? "Hide Filters" : "Show Filters",
                            systemImage: filtersExpanded ? "line.horizontal.3.decrease.circle.fill" : "line.horizontal.3.decrease.circle"
                        )
                        .font(.headline)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                
                // Conditionally show filters
                if filtersExpanded {
                    FiltersView(
                        filterByRegistrationNumber: $filterByRegistrationNumber,
                        filterByState:              $filterByState,
                        filterByCountry:            $filterByCountry,
                        filterByCompany:            $filterByCompany,
                        filterByFEI:                $filterByFEI,
                        filterByDeviceName:         $filterByDeviceName,
                        filterByUSAgentName:        $filterByUSAgentName,
                        filterByCreationDate:       $filterByCreationDate,
                        filterByExpiryYear:         $filterByExpiryYear,
                        applyFilters: {
                            applyFilters()
                            filtersExpanded = false
                        }
                    )
                }
                
                // Results count and list
                if viewModel.totalCount > 0 {
                    Text("Total Results: \(viewModel.totalCount)")
                        .font(.subheadline)
                        .padding(.bottom, 5)
                }
                
                // Show inline message when no results are found
                if viewModel.registrations.isEmpty && viewModel.didTriggerSearch {
                    Text("No results found. Try broadening your search criteria.")
                        .foregroundStyle(.secondary)
                        .padding()
                }
                
                RegistrationListView(viewModel: viewModel)
            }
            .navigationTitle("Registration Listings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Registration Listings")
                        .font(.title2)
                }
            }
        }
    }
    
    // Build the query string from active filters
    private func applyFilters() {
        var parts: [String] = []
        
        // OR group for operator state and country
        let locationQueries = [
            filterByState.isEmpty   ? nil : "registration.us_agent.state_code:\"\(filterByState)\"",
            filterByCountry.isEmpty ? nil : "registration.iso_country_code:\"\(filterByCountry)\""
        ].compactMap { $0 }
        
        if !locationQueries.isEmpty {
            let orQuery = locationQueries.joined(separator: " OR ")
            parts.append(locationQueries.count == 1 ? orQuery : "(\(orQuery))")
        }
        
        // Registration Number
        if !filterByRegistrationNumber.isEmpty {
            let input = filterByRegistrationNumber.trimmingCharacters(in: .whitespaces)
            if Int(input) != nil {
                // Exact numeric match wrapped in quotes
                parts.append("registration.registration_number:\"\(input)\"")
            } else {
                // Wildcard prefix match for text
                parts.append("registration.registration_number:\"\(input)*\"")
            }
        }
        
        // Company (Registration Name)
        if !filterByCompany.isEmpty {
            parts.append("registration.name:\"\(filterByCompany)*\"")
        }
        
        // FEI Number
        if !filterByFEI.isEmpty {
            let input = filterByFEI.trimmingCharacters(in: .whitespaces)
            if Int(input) != nil {
                parts.append("registration.fei_number:\"\(input)\"")
            } else {
                parts.append("registration.fei_number:\"\(input)*\"")
            }
        }
        
        // Device Name
        if !filterByDeviceName.isEmpty {
            parts.append("proprietary_name:\"\(filterByDeviceName)*\"")
        }
        
        // US Agent Name
        if !filterByUSAgentName.isEmpty {
            parts.append("registration.us_agent.name:\"\(filterByUSAgentName)*\"")
        }
        
        // Creation Year
        if !filterByCreationDate.isEmpty {
            let year = filterByCreationDate.trimmingCharacters(in: .whitespaces)
            if year.count == 4, Int(year) != nil {
                parts.append("products.created_date:[\(year)-01-01 TO \(year)-12-31]")
            } else {
                parts.append("products.created_date:\"\(filterByCreationDate)*\"")
            }
        }
        
        // Expiry Year
        if !filterByExpiryYear.isEmpty {
            let year = filterByExpiryYear.trimmingCharacters(in: .whitespaces)
            if year.count == 4, Int(year) != nil {
                parts.append("registration.reg_expiry_date_year:[\(year) TO \(year)]")
            } else {
                parts.append("registration.reg_expiry_date_year:\"\(filterByExpiryYear)*\"")
            }
        }
        
        let finalQuery = parts.joined(separator: "+AND+")
        print("Submitting query: \(finalQuery)")
        Task { await viewModel.search(finalQuery) }
    }
}

// MARK: – Filters UI
private struct FiltersView: View {
    @Binding var filterByRegistrationNumber: String
    @Binding var filterByState: String
    @Binding var filterByCountry: String
    @Binding var filterByCompany: String
    @Binding var filterByFEI: String
    @Binding var filterByDeviceName: String
    @Binding var filterByUSAgentName: String
    @Binding var filterByCreationDate: String
    @Binding var filterByExpiryYear: String
    let applyFilters: () -> Void

    @State private var showMoreFilters = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Filters", systemImage: "line.horizontal.3.decrease.circle")
                .font(.headline)
            
            // Core filters
            Group {
                TextField("Registration #", text: $filterByRegistrationNumber)
                HStack(spacing: 8) {
                    TextField("US Agent State Code (e.g. CA)", text: $filterByState)
                        .frame(maxWidth: .infinity)
                    TextField("Country Code (e.g. US)", text: $filterByCountry)
                        .frame(maxWidth: .infinity)
                }
                TextField("FEI Number", text: $filterByFEI)
                TextField("Creation Year (YYYY)", text: $filterByCreationDate)
            }
            .textFieldStyle(.roundedBorder)
            
            Button(action: { showMoreFilters.toggle() }) {
                Label(
                    showMoreFilters ? "Hide more filtering options" : "More filtering options",
                    systemImage: showMoreFilters ? "chevron.up.circle" : "chevron.down.circle"
                )
                .font(.subheadline)
            }
            .padding(.vertical, 4)
            
            if showMoreFilters {
                Group {
                    TextField("Registration Name", text: $filterByCompany)
                    TextField("Device Name", text: $filterByDeviceName)
                    TextField("US Agent Name", text: $filterByUSAgentName)
                    TextField("Expiry Year (YYYY)", text: $filterByExpiryYear)
                }
                .textFieldStyle(.roundedBorder)
            }
            
            Button(action: applyFilters) {
                Label("Apply Filters", systemImage: "slider.horizontal.3")
            }
            .padding(.vertical, 4)
        }
        .padding()
    }
}

// MARK: – List
private struct RegistrationListView: View {
    @ObservedObject var viewModel: RegistrationViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.registrations) { reg in
                NavigationLink(destination: RegistrationDetailView(registration: reg)) {
                    HStack(spacing: 12) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                        VStack(alignment: .leading) {
                            Text(reg.products?.first?.openfda?.deviceName
                                 ?? reg.proprietaryName?.first
                                 ?? "Unknown Device")
                                .font(.headline)
                            Text("Registration #: \(reg.registrationNumber)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .task { await viewModel.loadMoreIfNeeded(currentItem: reg) }
            }
            
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .listStyle(.plain)
    }
}
