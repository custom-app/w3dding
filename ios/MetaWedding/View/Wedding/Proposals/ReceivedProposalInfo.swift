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
        VStack {
            Text("Received from:")
            Text(proposal.address)
                .font(.system(size: 13))
                .padding(.top, 10)
                .padding(.horizontal, 20)
            Button {
                globalViewModel.sendTx()
            } label: {
                Text("Accept")
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(8)
            }
            .padding(.top, 40)
        }
    }
}
