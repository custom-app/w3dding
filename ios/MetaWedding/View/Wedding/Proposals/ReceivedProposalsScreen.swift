//
//  ReceivedProposalsScreen.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 10.04.2022.
//

import SwiftUI

struct ReceivedProposalsScreen: View {
    
    @EnvironmentObject
    var globalViewModel: GlobalViewModel
    
    @State
    var selectedProposal: Proposal?
    
    let geometry: GeometryProxy
    
    var body: some View {
        VStack {
            if globalViewModel.isReceivedProposalsLoaded {
                if globalViewModel.receivedProposals.isEmpty {
                    Text("There are no proposals addressed to you")
                        .font(Font.title2.weight(.bold))
                        .foregroundColor(Colors.darkPurple)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 36)
                } else if globalViewModel.receivedProposals.count == 1 {
                    ReceivedProposalInfo(proposal: globalViewModel.receivedProposals[0])
                } else {
                    List {
                        ForEach(globalViewModel.receivedProposals) { proposal in
                            Button {
                                selectedProposal = proposal
                            } label: {
                                HStack {
                                    Text(proposal.address)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
        }
        .frame(width: geometry.size.width, height: geometry.size.height)
        .sheet(item: $selectedProposal,
               onDismiss: { selectedProposal = nil }) { proposal in
            ReceivedProposalInfo(proposal: proposal)
                .environmentObject(globalViewModel)
        }
    }
}
