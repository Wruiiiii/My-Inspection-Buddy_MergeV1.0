import Foundation

struct FDAEnforcementResponse: Codable {
    let results: [FDAEnforcementRecord]?
    let error: FDAErrorPayload?
}

struct FDAEnforcementRecord: Codable, Identifiable, Hashable {
    var id: String { recallNumber }
    
    let recallNumber: String
    let recallingFirm: String
    let reasonForRecall: String
    let status: String
    let classification: String
    let codeInfo: String
    let productDescription: String
    
    enum CodingKeys: String, CodingKey {
        case recallNumber = "recall_number"
        case recallingFirm = "recalling_firm"
        case reasonForRecall = "reason_for_recall"
        case status
        case classification
        case codeInfo = "code_info"
        case productDescription = "product_description"
    }
}

struct FDAErrorPayload: Codable {
    let code: String
    let message: String
}

