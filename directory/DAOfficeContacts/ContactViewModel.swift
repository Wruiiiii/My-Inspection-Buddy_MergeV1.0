//
//  ContactViewModel.swift
//  DAContactsApp
//
//  Created by Tanay Doppalapudi on 6/17/25.
//

import Foundation
import Combine

class ContactViewModel: ObservableObject {
    @Published var contacts: [Contact] = []
    @Published var searchName: String = ""
    @Published var searchCounty: String = ""

    // Filtered result based on both fields
    var filteredContacts: [Contact] {
        contacts.filter { contact in
            let matchesName = searchName.isEmpty ||
                contact.firstName.localizedCaseInsensitiveContains(searchName) ||
                contact.lastName.localizedCaseInsensitiveContains(searchName)

            let matchesCounty = searchCounty.isEmpty ||
                contact.county.localizedCaseInsensitiveContains(searchCounty)

            return matchesName && matchesCounty
        }
    }

    func fetchContacts() {
//  "https://dacontactsapi-1.onrender.com/contacts") else {
//            print("Invalid URL")
            guard let url = URL(string: "https://inspectionbuddy-api.onrender.com/contacts") else { //new api
            print("Invalid URL")
                
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode([Contact].self, from: data)
                    DispatchQueue.main.async {
                        self.contacts = decoded
                        print("✅ Contacts loaded: \(decoded.count)")
                    }
                } catch {
                    print("❌ Decoding error: \(error)")
                }
            } else if let error = error {
                print("❌ Request error: \(error)")
            }
        }

        task.resume()
    }
}
