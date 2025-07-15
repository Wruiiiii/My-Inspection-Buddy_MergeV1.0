//
//  WarningLetter.swift
//  My Inspection Buddy_MergeV1.0
//
//  Created by Rae Wang on 7/10/25.
//

import Foundation

struct WarningLetter: Identifiable, Codable {
    var id: String { caseInjunctionID }
    
    let legalName: String
    let actionTakenDate: String
    let actionType: String
    let state: String
    let caseInjunctionID: String
    let warningLetterURL: String

    enum CodingKeys: String, CodingKey {
        case legalName = "LegalName"
        case actionTakenDate = "ActionTakenDate"
        case actionType = "ActionType"
        case state = "State"
        case caseInjunctionID = "CaseInjunctionID"
        case warningLetterURL = "warning_letter_url"
    }
}
