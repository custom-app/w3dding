//
//  ReceivedProposalAccepted.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 16.05.2022.
//

import SwiftUI

struct ReceivedProposalAccepted: View {
    
    var proposal: Proposal
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Received proposal from")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Colors.darkPurple.opacity(0.65))
                .padding(.horizontal, 20)
                .padding(.top, 24)
            
            Text(proposal.meta?.properties.firstPersonName ?? "")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Colors.darkPurple)
                .multilineTextAlignment(.center)
                .padding(.top, 24)
                .padding(.horizontal, 20)
            
            HStack {
                Spacer()
                Text("Address: \(proposal.address)")
                    .font(.system(size: 13).weight(.regular))
                    .fontWeight(.regular)
                    .foregroundColor(Colors.darkPurple)
                    .lineLimit(1)
                    .truncationMode(.middle)
                
                Button {
                    UIPasteboard.general.string = proposal.address
                } label: {
                    Image("ic_copy")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
                Spacer()
            }
            .padding(.horizontal, 28)
            .padding(.top, 8)
            
            Text("Waiting for your partner confirmation")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Colors.darkPurple)
                .multilineTextAlignment(.center)
                .padding(.top, 40)
                .padding(.horizontal, 20)
            
            Spacer()
        }
    }
}
