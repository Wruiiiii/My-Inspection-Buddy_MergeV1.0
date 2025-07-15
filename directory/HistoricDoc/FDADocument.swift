import Foundation

struct FDAResponse: Decodable {
    let results: [FDADocument]
    let meta: Meta
}

struct Meta: Decodable {
    let total: Int
    let page: Int
    let limit: Int
}

struct FDADocument: Codable, Identifiable {
    let id: Int
    let title: String?
    let docType: String?
    let year: Int?
    let text: String?
    let effectiveDate: String?

    var displayDocType: String {
        switch docType {
        case "pr":
            return "Press Release"
        case "talk":
            return "Talk"
        default:
            return docType ?? "Unknown"
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case docType = "doc_type"
        case year
        case text
        case effectiveDate = "effective_date"
    }
}

// MARK: - FDADocument Extensions

extension FDADocument {
    var displayType: String {
        switch docType?.lowercased() {
        case "pr":
            return "Press Release"
        case "pha":
            return "Public Health Alert"
        case "cn":
            return "Compliance Notice"
        case "sw":
            return "Safety Warning"
        case "talk":
            return "Talk"
        default:
            return docType?.capitalized ?? "Unknown"
        }
    }

    var department: String {
        guard let text = text else { return "Unknown" }
        let lines = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return lines.first ?? "Unknown"
    }

    var cleanBody: String {
        guard let raw = text else { return "" }
        let lines = raw.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let filtered = lines.filter { line in
            let letterCount = line.unicodeScalars.filter { CharacterSet.letters.contains($0) }.count
            return letterCount >= 4
        }
        return filtered.joined(separator: "\n\n")
    }
}
