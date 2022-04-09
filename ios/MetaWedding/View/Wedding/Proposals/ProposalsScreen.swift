//
//  ProposalsScreen.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 10.04.2022.
//

import SwiftUI

struct ProposalsScreen: View {
    
    @EnvironmentObject
    var globalViewModel: GlobalViewModel
    
    @EnvironmentObject
    var weddingViewModel: WeddingViewModel
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                Spacer()
                Button {
                    withAnimation {
                        weddingViewModel.selectedMyProposals = true
                    }
                } label: {
                    Text("My proposals")
                        .font(.system(size: 22))
                        .foregroundColor(weddingViewModel.selectedMyProposals ? .white : .gray)
                        .underline()
                }
                Spacer()
                Button {
                    withAnimation {
                        weddingViewModel.selectedMyProposals = false
                    }
                } label: {
                    Text("Proposals for me")
                        .font(.system(size: 22))
                        .foregroundColor(weddingViewModel.selectedMyProposals ? .gray : .white)
                        .underline()
                }
                Spacer()
            }
            .padding(.top, 14)
            Spacer()
            
            if weddingViewModel.selectedMyProposals {
                if globalViewModel.isAuthoredProposalsLoaded {
                    AuthoredProposalsScreen()
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.2)
                }
            } else {
                if globalViewModel.isReceivedProposalsLoaded {
                    ReceivedProposalsScreen()
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.2)
                }
            }
            Spacer()
        }
    }
}

struct ProposalsScreen_Previews: PreviewProvider {
    static var previews: some View {
        ProposalsScreen()
    }
}
