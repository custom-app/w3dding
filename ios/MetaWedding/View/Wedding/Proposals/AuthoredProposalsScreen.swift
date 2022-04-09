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
                    .sheet(isPresented: $showConstructor,
                          onDismiss: { showConstructor = false }) {
                       ProposalConstructor()
                    }
                    
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

    }
}

struct AuthoredProposalsScreen_Previews: PreviewProvider {
    static var previews: some View {
        AuthoredProposalsScreen()
    }
}
