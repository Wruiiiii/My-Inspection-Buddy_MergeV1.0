//
//  DAContentView.swift
//  DAContactsApp
//
//  Created by Tanay Doppalapudi on 6/17/25.
//

import SwiftUI

struct DAContentView: View {
    @StateObject var viewModel = ContactViewModel()

    var body: some View {
        NavigationView {
            VStack {
                // Name Search Field
                HStack {
                    Image(systemName: "person.text.rectangle")
                        .foregroundColor(.gray)
                    TextField("Search by name", text: $viewModel.searchName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)

                // County Search Field
                HStack {
                    Image(systemName: "map")
                        .foregroundColor(.gray)
                    TextField("Search by county", text: $viewModel.searchCounty)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding([.horizontal, .bottom])

                List(viewModel.filteredContacts) { contact in
                    NavigationLink(destination: ContactDetailView(contact: contact)) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "person.fill")
                                Text(contact.name)
                                    .font(.headline)
                            }

                            HStack {
                                Image(systemName: "location.fill")
                                Text(contact.county)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }

                            HStack {
                                Image(systemName: "phone.fill")
                                Text(contact.phone)
                                    .font(.footnote)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowSeparator(.visible)
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("DA Contacts")
            .onAppear {
                viewModel.fetchContacts()
            }
        }
    }
}
