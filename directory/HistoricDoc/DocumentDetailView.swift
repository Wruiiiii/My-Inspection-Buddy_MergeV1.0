//
//  DocumentDetailView.swift
//  HistoricalDocsApp
//
//  Created by Tanay Doppalapudi on 6/19/25.
//

import SwiftUI
import Foundation
import UIKit

struct DocumentDetailView: View {
    let document: FDADocument
    @State private var isShareSheetPresented = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Group {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.text")
                        Text(document.title ?? document.displayType)
                            .font(.title)
                            .bold()
                    }

                    if let year = document.year {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                            Text("Year: \(String(year))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

                    if let effectiveDate = document.effectiveDate {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar.badge.clock")
                            Text("Effective Date: \(effectiveDate)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Divider()

                HStack(spacing: 6) {
                    Image(systemName: "doc.append")
                    Text("Document Text")
                        .font(.headline)
                }

                Text(document.cleanBody.isEmpty ? "No content available." : document.cleanBody)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Document Detail")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isShareSheetPresented = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
                .disabled(document.text == nil)
            }
        }
        .sheet(isPresented: $isShareSheetPresented) {
            if let text = document.text {
                ActivityView(activityItems: [text])
            }
        }
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
