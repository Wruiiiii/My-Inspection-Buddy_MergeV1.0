//
//  FDARegistration.swift
//  LicensingDatabaseApp
//
//  Updated by ChatGPT on 7/10/25.
//

import Foundation

// MARK: - Top-level API wrapper
// Decodes BOTH the result list and the total count.
struct FDAResponses: Decodable {
    let meta: Meta
    let results: [FDARegistration]

    struct Meta: Decodable {
        let results: MetaResults
        struct MetaResults: Decodable {
            let total: Int
        }
    }
}

// MARK: - One registration record
struct FDARegistration: Identifiable, Decodable {
    // Raw JSON fields
    let proprietaryName: [String]?
    let establishmentType: [String]?
    let registration: Core?
    let products: [Product]?

    // Computed properties for filters & list display
    var registrationNumber: String {
        registration?.registrationNumber ?? "Unknown"
    }
    var feiNumber: String {
        registration?.feiNumber ?? "Unknown"
    }
    var registrationName: String {
        registration?.name ?? "Unknown"
    }
    var usAgentName: String {
        registration?.usAgent?.name ?? "Unknown"
    }
    var usAgentStateCode: String {
        registration?.usAgent?.stateCode ?? "Unknown"
    }
    var creationDate: String {
        products?.first?.createdDate ?? "Unknown"
    }
    var deviceClass: String {
        products?.first?.openfda?.deviceClass ?? "Unknown"
    }

    // Exposed for detail view
    var expiryYear: String? {
        registration?.regExpiryDateYear
    }
    var ownerOperatorFirmName: String? {
        registration?.ownerOperator?.firmName
    }

    // Composite ID to guarantee uniqueness
    var id: String {
        let code = products?.first?.productCode ?? UUID().uuidString
        return "\(registrationNumber)-\(code)"
    }

    enum CodingKeys: String, CodingKey {
        case proprietaryName   = "proprietary_name"
        case establishmentType = "establishment_type"
        case registration      = "registration"
        case products
    }

    // MARK: - Nested “registration” JSON object
    struct Core: Decodable {
        let registrationNumber: String?
        let name:                String?
        let feiNumber:           String?
        let stateCode:           String?
        let isoCountryCode:      String?
        let usAgent:             UsAgent?
        let regExpiryDateYear:   String?
        let ownerOperator:       OwnerOperator?

        enum CodingKeys: String, CodingKey {
            case registrationNumber = "registration_number"
            case name
            case feiNumber          = "fei_number"
            case stateCode          = "state_code"
            case isoCountryCode     = "iso_country_code"
            case usAgent            = "us_agent"
            case regExpiryDateYear  = "reg_expiry_date_year"
            case ownerOperator      = "owner_operator"
        }

        struct UsAgent: Decodable {
            let name: String?
            let stateCode: String?    // US Agent's state code

            enum CodingKeys: String, CodingKey {
                case name
                case stateCode = "state_code"
            }
        }

        struct OwnerOperator: Decodable {
            let firmName: String?
            enum CodingKeys: String, CodingKey {
                case firmName = "firm_name"
            }
        }
    }

    // MARK: - Product subtype
    struct Product: Decodable {
        let productCode: String?
        let createdDate: String?
        let openfda:     OpenFDA?

        enum CodingKeys: String, CodingKey {
            case productCode = "product_code"
            case createdDate = "created_date"
            case openfda
        }

        struct OpenFDA: Decodable {
            let deviceName:       String?
            let regulationNumber: String?
            let deviceClass:      String?

            enum CodingKeys: String, CodingKey {
                case deviceName       = "device_name"
                case regulationNumber = "regulation_number"
                case deviceClass      = "device_class"
            }
        }
    }
}
