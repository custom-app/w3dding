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
    
    let geometry: GeometryProxy
    
    var body: some View {
        VStack {
            
            if globalViewModel.isReceivedProposalsLoaded &&
                !globalViewModel.receivedProposals.isEmpty {
                ProposalsMenu()
                    .padding(.top, 14)
                    .padding(.leading, 16)
            }
            
            if globalViewModel.selectedMyProposals {
                if globalViewModel.isAuthoredProposalsLoaded &&
                    (globalViewModel.authoredProposals.count != 1 ||
                     globalViewModel.authoredProposals.first?.meta != nil) {
                    AuthoredProposalsScreen(geometry: geometry)
                } else { 
                    GeometryReader { innerGeometry in
                        VStack(spacing: 0) {
                            Spacer()
                            WeddingProgress()
                            Text("Loading data")
                                .font(Font.headline.bold())
                                .foregroundColor(Colors.darkPurple)
                                .padding(.top, 24)
                            Spacer()
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height-100)
                    }
                }
            } else {
                if globalViewModel.isReceivedProposalsLoaded &&
                    (globalViewModel.receivedProposals.count != 1 ||
                     globalViewModel.receivedProposals.first?.meta != nil) {
                    ReceivedProposalsScreen(geometry: geometry)
                } else {
                    VStack(spacing: 0) {
                        Spacer()
                        WeddingProgress()
                        Text("Loading data")
                            .font(Font.headline.bold())
                            .foregroundColor(Colors.darkPurple)
                            .padding(.top, 24)
                        Spacer()
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height-100)
                }
            }
        }
        
        if (globalViewModel.selectedMyProposals &&
            globalViewModel.isAuthoredProposalsLoaded &&
            globalViewModel.authoredProposals.isEmpty &&
            !globalViewModel.isProposalActionPending) ||
            (!globalViewModel.selectedMyProposals &&
             globalViewModel.isReceivedProposalsLoaded &&
             globalViewModel.receivedProposals.count == 1 &&
             !globalViewModel.isProposalActionPending) {
            Spacer()                // Used to create some space in scrollview to make bottom
                .frame(height: 240) // textfields in proposal constructor (or proposal acception) visible while keyboard shown
        }
    }
}

struct ProposalsMenu: View {
    
    @EnvironmentObject
    var globalViewModel: GlobalViewModel
    
    var body: some View {
        HStack {
            HStack(spacing: 0) {
                Text("Outgoing")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(globalViewModel.selectedMyProposals ?
                                     Colors.darkPurple : Colors.darkPurple.opacity(0.65))
                    .padding(.vertical, 15)
                    .padding(.horizontal, 12)
                    .background(Color.white.opacity(globalViewModel.selectedMyProposals ? 1 : 0))
                    .cornerRadius(50)
                    .onTapGesture {
                        withAnimation {
                            globalViewModel.selectedMyProposals = true
                        }
                    }
                    .disabled(globalViewModel.selectedMyProposals)
                    .padding(5)
                
                Text("Incoming")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(globalViewModel.selectedMyProposals ?
                                     Colors.darkPurple.opacity(0.65) : Colors.darkPurple)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 12)
                    .background(Color.white.opacity(globalViewModel.selectedMyProposals ? 0 : 1))
                    .cornerRadius(50)
                    .onTapGesture {
                        withAnimation {
                            globalViewModel.selectedMyProposals = false
                        }
                    }
                    .disabled(!globalViewModel.selectedMyProposals)
                    .padding(.leading, 7)
                    .padding(.vertical, 5)
                    .padding(.trailing, 5)
            }
            .background(Color.white.opacity(0.5))
            .cornerRadius(30)
            
            Spacer()
        }
    }
}
