//
//  PPContentView.swift
//  PrivacyPolicyDisplay
//
//  Created by Tanay Doppalapudi on 6/25/25.
//

import SwiftUI

struct PPContentView: View {
    var body: some View {
        NavigationStack {
            PrivacyPoliciesView()
        }
    }
}

struct PPContentView_Previews: PreviewProvider {
    static var previews: some View {
        PPContentView()
    }
}
