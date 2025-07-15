import SwiftUI

// Model for the parsed itinerary details
struct ParsedItinerary {
    var tripName: String = "N/A"
    var startDate: String = "N/A"
    var endDate: String = "N/A"
    var location: String = "N/A"
    var totalCost: String = "N/A"
    var confirmation: String = "N/A"
    var hotelName: String = "N/A"
}

struct SAPTravelInfoView: View {
    @State private var itinerary: ParsedItinerary?

    var body: some View {
        VStack {
            if let itinerary = itinerary {
                Form {
                    Section(header: Text("Trip Overview")) {
                        // Using the renamed helper view
                        SAPInfoRow(label: "Trip Name", value: itinerary.tripName)
                        SAPInfoRow(label: "Total Estimated Cost", value: itinerary.totalCost)
                    }
                    
                    Section(header: Text("Hotel Information")) {
                        SAPInfoRow(label: "Hotel", value: itinerary.hotelName)
                        SAPInfoRow(label: "Location", value: itinerary.location)
                        SAPInfoRow(label: "Confirmation #", value: itinerary.confirmation)
                    }
                    
                    Section(header: Text("Dates")) {
                        SAPInfoRow(label: "Start Date", value: itinerary.startDate)
                        SAPInfoRow(label: "End Date", value: itinerary.endDate)
                    }
                }
            } else {
                Text("Could not load itinerary. Please check the 'trip_itinerary.ics' file in the project.")
                    .padding()
                    .multilineTextAlignment(.center)
            }
        }
        .onAppear(perform: loadItinerary)
        .navigationTitle("SAP Travel Info")
    }
    
    private func loadItinerary() {
        guard let path = Bundle.main.path(forResource: "trip_itinerary", ofType: "ics"),
              let content = try? String(contentsOfFile: path) else {
            print("Error: Could not find or load trip_itinerary.ics")
            return
        }
        
        var parsedData = ParsedItinerary()
        
        if let descriptionRange = content.range(of: "DESCRIPTION:"),
           let endDescriptionRange = content.range(of: "\nUID:") {
            let descriptionBlock = String(content[descriptionRange.upperBound..<endDescriptionRange.lowerBound])
            let cleanedDescription = descriptionBlock
                .replacingOccurrences(of: "\r\n ", with: "")
                .replacingOccurrences(of: "\\n", with: "\n")
                .replacingOccurrences(of: "\\,", with: ",")

            parsedData.tripName = extractValue(from: cleanedDescription, forKey: "Trip Name:")
            parsedData.startDate = extractValue(from: cleanedDescription, forKey: "Start Date:")
            parsedData.endDate = extractValue(from: cleanedDescription, forKey: "End Date:")
            parsedData.totalCost = extractValue(from: cleanedDescription, forKey: "Total Estimated Cost:")
            parsedData.confirmation = extractValue(from: cleanedDescription, forKey: "Confirmation:")
            
            if let hotelSection = cleanedDescription.components(separatedBy: "Reservations").last {
                let lines = hotelSection.split(separator: "\n")
                if lines.count > 2 {
                    parsedData.hotelName = String(lines[2]).trimmingCharacters(in: .whitespacesAndNewlines)
                    parsedData.location = String(lines[4]).trimmingCharacters(in: .whitespacesAndNewlines) + ", " + String(lines[5]).trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }
        
        self.itinerary = parsedData
    }
    
    private func extractValue(from text: String, forKey key: String) -> String {
        guard let range = text.range(of: key) else { return "N/A" }
        let subsequentText = text[range.upperBound...]
        let value = subsequentText.split(separator: "\n").first?.trimmingCharacters(in: .whitespaces)
        return String(value ?? "N/A")
    }
}

// The helper view has been renamed from InfoRow to SAPInfoRow
struct SAPInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
        }
        .padding(.vertical, 4)
    }
}

struct SAPTravelInfoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SAPTravelInfoView()
        }
    }
}


//import SwiftUI
//
//// 1. Data Model: Represents a single travel record
//struct SAPTrip: Identifiable {
//    let id: String
//    let destination: String
//    let startDate: String
//    let endDate: String
//    let status: String
//    let cost: String
//}
//
//// 2. View: Displays the list of travel information
//struct SAPTravelInfoView: View {
//    
//    // Mock data, just like in the JavaScript file.
//    // This would be replaced with data from an API in a real app.
//    let travelData: [SAPTrip] = [
//        .init(id: "1", destination: "New York City", startDate: "2024-11-01", endDate: "2024-11-05", status: "Confirmed", cost: "$1200"),
//        .init(id: "2", destination: "Los Angeles", startDate: "2024-12-10", endDate: "2024-12-15", status: "Pending", cost: "$950"),
//        .init(id: "3", destination: "Chicago", startDate: "2025-01-20", endDate: "2025-01-22", status: "Confirmed", cost: "$780")
//    ]
//    
//    var body: some View {
//        // Use a List to display the data in a scrollable format.
//        List(travelData) { trip in
//            TripRowView(trip: trip)
//        }
//        .navigationTitle("SAP Travel Info")
//    }
//}
//
//// 3. Helper View: A custom view for a single row in the list
//struct TripRowView: View {
//    let trip: SAPTrip
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            HStack {
//                Image(systemName: "airplane.departure")
//                    .foregroundColor(.accentColor)
//                Text(trip.destination)
//                    .font(.headline)
//                Spacer()
//                Text(trip.status)
//                    .font(.caption.bold())
//                    .foregroundColor(.white)
//                    .padding(.horizontal, 8)
//                    .padding(.vertical, 4)
//                    .background(trip.status == "Confirmed" ? Color.green : Color.orange)
//                    .cornerRadius(8)
//            }
//            
//            Divider()
//            
//            HStack(spacing: 20) {
//                VStack(alignment: .leading) {
//                    Text("Start Date").font(.caption).foregroundColor(.secondary)
//                    Text(trip.startDate)
//                }
//                VStack(alignment: .leading) {
//                    Text("End Date").font(.caption).foregroundColor(.secondary)
//                    Text(trip.endDate)
//                }
//                Spacer()
//                VStack(alignment: .trailing) {
//                    Text("Cost").font(.caption).foregroundColor(.secondary)
//                    Text(trip.cost).fontWeight(.semibold)
//                }
//            }
//        }
//        .padding(.vertical, 8)
//    }
//}
//
//
//// Preview for designing the view
//struct SAPTravelInfoView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            SAPTravelInfoView()
//        }
//    }
//}
