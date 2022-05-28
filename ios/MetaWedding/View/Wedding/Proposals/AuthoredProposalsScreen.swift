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
    var selectedProposal: Proposal?
    
    let geometry: GeometryProxy
    
    var body: some View {
        VStack(spacing: 0) {
            if globalViewModel.isAuthoredProposalsLoaded {
                if globalViewModel.authoredProposals.isEmpty {
                    
                    VStack(spacing: 0) {
                        Text("You are single")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Colors.darkGrey)
                            .padding(.top, 16)
                        
                        ProposalConstructor()
                            .padding(.top, 8)
                    }
                } else {
                    let headerShown = globalViewModel.isReceivedProposalsLoaded &&
                                      !globalViewModel.receivedProposals.isEmpty
                    ZStack {
                        VStack(spacing: 0) {
                            if globalViewModel.authoredProposals.count == 1 {
                                if let proposal = globalViewModel.authoredProposals.first {
                                    if proposal.receiverAccepted, proposal.meta != nil {
                                        AuthoredProposalAccepted(proposal: proposal)
                                            .frame(height: geometry.size.height - (headerShown ? 100 : 0))
                                    } else {
                                        AuthoredProposalPending(proposal: proposal)
                                            .frame(height: geometry.size.height - (headerShown ? 100 : 0))
                                    }
                                }
                            } else {
                                VStack(spacing: 0) {
                                    ForEach(globalViewModel.authoredProposals) { proposal in
                                        VStack(alignment: .leading, spacing: 0) {
                                            
                                            HStack(spacing: 0) {
                                                VStack(alignment: .leading, spacing: 0) {
                                                    let name = proposal.meta?.properties.secondPersonName ?? ""
                                                    Text(name == "" ? "Outgoing proposal" : name)
                                                        .font(Font.headline.weight(.bold))
                                                        .foregroundColor(Colors.darkPurple)
                                                    
                                                    HStack {
                                                        Text("\(proposal.address)")
                                                            .font(Font.footnote.weight(.regular))
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
                                                                .frame(width: 20)
                                                        }
                                                    }
                                                    .padding(.trailing, 60)
                                                    .padding(.top, 8)
                                                    
                                                    Text(proposal.receiverAccepted ? "Ready to mint!" : "Waiting for partner reply")
                                                        .font(Font.headline.weight(.bold))
                                                        .foregroundColor(Colors.darkPurple.opacity(0.65))
                                                        .padding(.top, 8)
                                                }
                                                
                                                Spacer()
                                                
                                                ZStack(alignment: .leading) {
                                                    ZStack {
                                                        if let image = proposal.receiverImage {
                                                            Image(uiImage: image)
                                                                .resizable()
                                                                .scaledToFill()
                                                                .frame(width: 48, height: 48)
                                                                .clipped()
                                                        } else {
                                                            Image("ic_heart_secondary")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: 24)
                                                                .padding(.top, 5)
                                                        }
                                                    }
                                                    .frame(width: 48, height: 48)
                                                    .background(Colors.mainBackground)
                                                    .cornerRadius(50)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 50)
                                                            .stroke(Colors.darkPurple, lineWidth: 2)
                                                    )
                                                    .padding(.leading, 32)

                                                    ZStack {
                                                        if let image = proposal.authorImage {
                                                            Image(uiImage: image)
                                                                .resizable()
                                                                .scaledToFill()
                                                                .frame(width: 48, height: 48)
                                                                .clipped()
                                                        } else {
                                                            Image("ic_heart")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: 24)
                                                                .padding(.top, 5)
                                                        }
                                                    }
                                                    .frame(width: 48, height: 48)
                                                    .background(Colors.mainBackground)
                                                    .cornerRadius(50)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 50)
                                                            .stroke(Colors.purple, lineWidth: 2)
                                                    )
                                                }
                                            }
                                        }
                                        .padding(16)
                                        .background(Color.white.opacity(0.5))
                                        .cornerRadius(10)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .onTapGesture {
                                            selectedProposal = proposal
                                        }
                                    }
                                }
                                .sheet(item: $selectedProposal,
                                       onDismiss: { selectedProposal = nil }) { proposal in
                                    ZStack {
                                        Image("DefaultBackground")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .edgesIgnoringSafeArea(.all)
                                        
                                        VStack(spacing: 0) {
                                            AuthoredProposalInfo(proposal: proposal)
                                        }
                                    }
                                    .environmentObject(globalViewModel)
                                }
                            }
                        }
                    }
                
                }
            }
        }

    }
}

struct NewProposalBar: View {
    
    @EnvironmentObject
    var globalViewModel: GlobalViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Messed up with filling out the proposal?")
                .font(Font.subheadline.weight(.bold))
                .foregroundColor(Colors.darkPurple.opacity(0.65))
            
            Button {
                globalViewModel.showConstructorSheet = true
            } label: {
                Text("New proposal")
                    .font(Font.subheadline.weight(.bold))
                    .foregroundColor(Colors.purple)
            }
            .padding(.top, 10)
            .sheet(isPresented: $globalViewModel.showConstructorSheet,
                  onDismiss: { globalViewModel.showConstructorSheet = false }) {
                ZStack {
                    Image("DefaultBackground")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 0) {
                        ProposalConstructor()
                    }
                }
                .environmentObject(globalViewModel)
            }
        }
        .padding(.horizontal, 28)
    }
    
}


