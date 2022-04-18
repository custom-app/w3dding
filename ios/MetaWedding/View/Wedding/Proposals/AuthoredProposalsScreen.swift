//
//  AuthoredProposalsScreen.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 10.04.2022.
//

import SwiftUI

struct AuthoredProposalsScreen: View {
    
    @EnvironmentObject
    var globalViewModel: GlobalViewModel
    
    @State
    var showConstructor = false
    
    @State
    var selectedProposal: Proposal?
    
    var body: some View {
        VStack {
            if globalViewModel.isAuthoredProposalsLoaded {
                if globalViewModel.authoredProposals.isEmpty {
                    ProposalConstructor()
                } else {
                    Button {
                        showConstructor = true
                    } label: {
                        Text("New proposal")
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                    .padding(.top, 50)
                    .padding(.bottom, 20)
                    .sheet(isPresented: $showConstructor,
                          onDismiss: { showConstructor = false }) {
                       ProposalConstructor()
                    }
                    
                    ForEach(globalViewModel.authoredProposals) { proposal in
                        Button {
                            selectedProposal = proposal
                        } label: {
                            HStack {
                                Text(proposal.address)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .sheet(item: $selectedProposal,
                           onDismiss: { selectedProposal = nil }) { proposal in
                        AuthoredProposalInfo(proposal: proposal)
                    }
                }
            }
        }

    }
}

struct AuthoredProposalsScreen_Previews: PreviewProvider {
    static var previews: some View {
        AuthoredProposalsScreen()
    }
}
