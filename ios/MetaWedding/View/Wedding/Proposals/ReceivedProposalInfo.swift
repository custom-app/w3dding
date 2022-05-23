//
//  ReceivedProposalSheet.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 10.04.2022.
//

import SwiftUI

struct ReceivedProposalInfo: View {
    
    @EnvironmentObject
    var globalViewModel: GlobalViewModel
    
    var proposal: Proposal
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("DefaultBackground")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 0) {
                        if proposal.receiverAccepted {
                            ReceivedProposalAccepted(proposal: proposal)
                        } else {
                            ReceivedProposalPending(proposal: proposal)
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    
                    Spacer()
                        .frame(height: 240)
                }
            }
        }
    }
}
