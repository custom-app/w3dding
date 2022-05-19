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
        GeometryReader { geometry in
            ZStack {
                Image("DefaultBackground")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 0) {
                    if proposal.receiverAccepted, proposal.meta != nil {
                        AuthoredProposalAccepted(proposal: proposal)
                    } else {
                        AuthoredProposalPending(proposal: proposal)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}
