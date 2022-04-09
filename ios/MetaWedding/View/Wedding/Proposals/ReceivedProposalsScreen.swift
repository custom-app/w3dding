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
    
    var body: some View {
        VStack {
            if globalViewModel.isReceivedProposalsLoaded {
                if globalViewModel.receivedProposals.isEmpty {
                    Text("There is no proposals for you")
                } else if globalViewModel.receivedProposals.count == 1 {
                    ReceivedProposalInfo()
                } else {
                    Text("List of proposals here")
                        .onTapGesture {
                            // show proposal info sheet
                        }
                        .sheet(item: $selectedProposal,
                               onDismiss: { selectedProposal = nil }) { proposal in
                            AuthoredProposalInfo()
                        }
                }
            }
        }
        .sheet(item: $selectedProposal,
               onDismiss: { selectedProposal = nil}) { proposal in
            ReceivedProposalInfo()
        }
    }
}

struct ReceivedProposalsScreen_Previews: PreviewProvider {
    static var previews: some View {
        ReceivedProposalsScreen()
    }
}
