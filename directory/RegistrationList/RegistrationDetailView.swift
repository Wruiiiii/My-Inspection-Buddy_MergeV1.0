//
//  RegistrationDetailView.swift
//  LicensingDatabaseApp
//
//  Created by Tanay Doppalapudi on 7/8/25.
//  Updated by ChatGPT on 7/10/25.
//

import SwiftUI

struct RegistrationDetailView: View {
    let registration: FDARegistration

    var body: some View {
        List {
            // MARK: – Registration Info
            Section(header: Text("Registration Info")) {
                HStack {
                    Image(systemName: "number.circle")
                    Text("Registration Number")
                    Spacer()
                    Text(registration.registrationNumber)
                        .foregroundStyle(.secondary)
                }

                if let types = registration.establishmentType, !types.isEmpty {
                    ForEach(types, id: \.self) { type in
                        HStack {
                            Image(systemName: "building.2")
                            Text("Establishment Type")
                            Spacer()
                            Text(type)
                                .foregroundStyle(.secondary)
                        }
                    }
                } else {
                    HStack {
                        Image(systemName: "building.2")
                        Text("Establishment Type")
                        Spacer()
                        Text("None")
                            .foregroundStyle(.secondary)
                    }
                }

                HStack {
                    Image(systemName: "building")
                    Text("Company Name")
                    Spacer()
                    Text(registration.registrationName)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Image(systemName: "number.circle")
                    Text("FEI Number")
                    Spacer()
                    Text(registration.feiNumber)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Image(systemName: "globe")
                    Text("Country")
                    Spacer()
                    Text(registration.registration?.isoCountryCode ?? "—")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Image(systemName: "map")
                    Text("State")
                    Spacer()
                    Text(registration.registration?.stateCode ?? "—")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Image(systemName: "person.crop.circle")
                    Text("US Agent Name")
                    Spacer()
                    Text(registration.usAgentName)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Image(systemName: "calendar.badge.exclamationmark")
                    Text("Expiry Year")
                    Spacer()
                    Text(registration.expiryYear ?? "—")
                        .foregroundStyle(.secondary)
                }
            }

            // MARK: – Products
            Section(header: Text("Products")) {
                if let products = registration.products, !products.isEmpty {
                    ForEach(products.indices, id: \.self) { idx in
                        let product = products[idx]
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "ipad.and.iphone")
                                Text("Device Name")
                                Spacer()
                                Text(product.openfda?.deviceName ?? "—")
                                    .foregroundStyle(.secondary)
                            }
                            HStack {
                                Image(systemName: "tag")
                                Text("Product Code")
                                Spacer()
                                Text(product.productCode ?? "—")
                                    .foregroundStyle(.secondary)
                            }
                            HStack {
                                Image(systemName: "gavel")
                                Text("Regulation #")
                                Spacer()
                                Text(product.openfda?.regulationNumber ?? "—")
                                    .foregroundStyle(.secondary)
                            }
                            HStack {
                                Image(systemName: "doc.text")
                                Text("Device Class")
                                Spacer()
                                Text(product.openfda?.deviceClass ?? "—")
                                    .foregroundStyle(.secondary)
                            }
                            HStack {
                                Image(systemName: "calendar")
                                Text("Creation Date")
                                Spacer()
                                Text(product.createdDate ?? "—")
                                    .foregroundStyle(.secondary)
                            }
                            HStack {
                                Image(systemName: "person.2")
                                Text("Owner Operator Firm")
                                Spacer()
                                Text(registration.ownerOperatorFirmName ?? "—")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } else {
                    HStack {
                        Image(systemName: "archivebox")
                        Text("Products")
                        Spacer()
                        Text("None")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Details")
    }
}

