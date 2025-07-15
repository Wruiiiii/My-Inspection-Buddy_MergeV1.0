//
//  WarningLetterSearchView.swift
//  My Inspection Buddy_MergeV1.0
//
//  Created by Rae Wang on 7/10/25.
//

import SwiftUI

struct WarningLetterSearchView: View {
    @StateObject private var viewModel = WarningLetterViewModel()
    
    var body: some View {
        Form {
            Section(header: Text("Firm Name")) {
                TextField("Enter firm name", text: $viewModel.firmName)
            }
            
            Section {
                Button(action: {
                    viewModel.searchWarningLetters()
                }) {
                    HStack {
                        Spacer()
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Search")
                        }
                        Spacer()
                    }
                }
                .disabled(viewModel.isLoading)
            }
            
            // Show error or results
            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.gray)
                }
            } else if !viewModel.results.isEmpty {
                WarningLetterResultsView(results: viewModel.results)
            }
        }
        .navigationTitle("Warning Letter Search")
    }
}

struct WarningLetterResultsView: View {
    let results: [WarningLetter]
    
    var body: some View {
        Section(header: Text("Results")) {
            List(results) { letter in
                VStack(alignment: .leading, spacing: 8) {
                    Text(letter.legalName)
                        .font(.headline)
                    
                    Text("Date: \(letter.actionTakenDate)")
                    Text("Action Type: \(letter.actionType)")
                    Text("State: \(letter.state)")
                    
                    if let url = URL(string: letter.warningLetterURL) {
                        Link("View Warning Letter (PDF)", destination: url)
                            .padding(.top, 4)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
}
