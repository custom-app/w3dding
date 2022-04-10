//
//  AuthoredProposalSheet.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 10.04.2022.
//

import SwiftUI

struct AuthoredProposalInfo: View {
    
    var proposal: Proposal
    
    var body: some View {
        VStack {
            Text("Proposal to:")
            Text(proposal.address)
                .font(.system(size: 13))
                .padding(.top, 10)
                .padding(.horizontal, 20)
        }
    }
}
