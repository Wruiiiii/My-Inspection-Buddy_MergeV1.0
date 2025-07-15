//
//  PrivacyPoliciesView.swift
//  PrivacyPolicyDisplay
//
//  Created by Tanay Doppalapudi on 6/25/25.
//

import SwiftUI
import PDFKit

struct Policy: Identifiable {
    let id = UUID()
    let title: String    // what shows in the list
    let fileName: String // exact filename (including “.pdf”) in your bundle
}

struct PrivacyPoliciesView: View {

    private let policies: [Policy] = [
        .init(title: "Section 11-4000 of the Public Health Administration Manual (PHAM)", fileName: "PHAM114000.pdf"),
        .init(title: "HIPAA Administrative Simplification", fileName: "HIPAA.pdf"),
        .init(title: "Sections 5310 of State Administration Manual (SAM)", fileName: "SAM5310.pdf"),
        .init(title: "Sections 5320.3 of State Administration Manual (SAM)", fileName: "SAM5320.3.pdf"),
        .init(title: "CDPH Azure Governance Framework", fileName: "Azure.pdf")
    ]
    
    @State private var fullscreenPolicy: Policy? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Since our app is targeted to a tablet, its mobile and portable nature brings privacy considerations that will be addressed by compliance with CDPH’s privacy policies. Please refer to the below documents:")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)

                    ForEach(policies) { policy in
                        DisclosureGroup {
                            PDFKitView(fileName: policy.fileName)
                                .frame(height: 400)
                        } label: {
                            HStack {
                                Label {
                                    Text(policy.title)
                                        .font(.title3)
                                } icon: {
                                    Image(systemName: "doc.text.fill")
                                        .foregroundColor(.accentColor)
                                }

                                Spacer()

                                Button {
                                    fullscreenPolicy = policy
                                } label: {
                                    Image(systemName: "arrow.up.left.and.arrow.down.right.circle.fill")
                                        .imageScale(.large)
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
                .padding()
            }
            .fullScreenCover(item: $fullscreenPolicy) { policy in
                NavigationStack {
                    PDFKitView(fileName: policy.fileName)
                        .ignoresSafeArea()
                        .navigationTitle(policy.title)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Done") {
                                    fullscreenPolicy = nil
                                }
                            }
                        }
                }
                .ignoresSafeArea()
            }
            .navigationTitle("Privacy Policies")
        }
    }
}

struct PrivacyPoliciesView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPoliciesView()
    }
}

// MARK: – PDF rendering bridge

struct PDFKitView: UIViewRepresentable {
    let fileName: String

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        if let url = Bundle.main.url(forResource: fileName, withExtension: nil) {
            pdfView.document = PDFDocument(url: url)
        }
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) { }
}
