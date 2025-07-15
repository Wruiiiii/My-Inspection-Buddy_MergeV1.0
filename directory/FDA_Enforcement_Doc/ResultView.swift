//
//  ResultView.swift
//  My Inspection Buddy_MergeV1.0
//
//  Created by Rae Wang on 7/14/25.
//

import SwiftUI

struct RecallResultsView: View {
    let recalls: [FDAEnforcementRecord]

    var body: some View {
        List(recalls) { recall in
            NavigationLink(destination: RecallDetailView(recall: recall)) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(recall.recallingFirm)
                        .font(.headline)
                    Text(recall.productDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    Text(recall.recallNumber)
                        .font(.caption)
                        .foregroundColor(.accentColor)
                }
                .padding(.vertical, 4)
            }
        }
    }
}

struct RecallDetailView: View {
    let recall: FDAEnforcementRecord

    var body: some View {
        List {
            Section(header: Text("Recall Summary")) {
                InfoRow(label: "Recall Number", value: recall.recallNumber)
                InfoRow(label: "Status", value: recall.status)
                InfoRow(label: "Classification", value: recall.classification)
            }
            
            Section(header: Text("Company Information")) {
                InfoRow(label: "Recalling Firm", value: recall.recallingFirm)
            }
            
            Section(header: Text("Product Information")) {
                 VStack(alignment: .leading, spacing: 5) {
                    Text("Product Description")
                        .font(.headline)
                    Text(recall.productDescription)
                }
                .padding(.vertical, 5)

                VStack(alignment: .leading, spacing: 5) {
                    Text("Code Information")
                        .font(.headline)
                    Text(recall.codeInfo)
                }
                .padding(.vertical, 5)
            }
            
            Section(header: Text("Reason for Recall")) {
                Text(recall.reasonForRecall)
                    .padding(.vertical, 5)
            }
        }
        .listStyle(.grouped)
        .navigationTitle("Recall Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .fontWeight(.bold)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}
