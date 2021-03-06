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
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundColor(Colors.darkPurple.opacity(0.65))
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
                                        AuthoredProposalListItem(proposal: proposal, selectedProposal: $selectedProposal)
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

struct AuthoredProposalListItem: View {
    
    var proposal: Proposal
    
    @Binding
    var selectedProposal: Proposal?
    
    @State
    private var animatingAuthorPicture = false
    
    @State
    private var animatingReceiverPicture = false
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    let name = proposal.meta?.properties.secondPersonName ?? ""
                    Text(name == "" ? "Outgoing proposal" : name)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Colors.darkPurple)
                    
                    HStack {
                        Text("\(proposal.address)")
                            .font(.system(size: 13))
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
                    }
                    .padding(.trailing, 60)
                    .padding(.top, 8)
                    
                    Text(proposal.receiverAccepted ? "Ready to mint!" : "Waiting for partner reply")
                        .font(.system(size: 17, weight: .bold))
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
                                .opacity(animatingReceiverPicture ? 0.1 : 1)
                                .animation(Animation.easeIn(duration: 1).repeatForever())
                                .onAppear(perform: {
                                    if let image = proposal.meta?.properties.secondPersonImage, !image.isEmpty {
                                        animatingReceiverPicture = true
                                    }
                                })
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
                                .opacity(animatingAuthorPicture ? 0.1 : 1)
                                .animation(Animation.easeIn(duration: 1).repeatForever())
                                .onAppear(perform: {
                                    if let image = proposal.meta?.properties.firstPersonImage, !image.isEmpty {
                                        animatingAuthorPicture = true
                                    }
                                })
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

struct NewProposalBar: View {
    
    @EnvironmentObject
    var globalViewModel: GlobalViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Messed up with filling out the proposal?")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Colors.darkPurple.opacity(0.65))
            
            Button {
                globalViewModel.showConstructorSheet = true
            } label: {
                Text("New proposal")
                    .font(.system(size: 15, weight: .bold))
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
                .alert(item: $globalViewModel.alert) { alert in
                    alert.alert()
                }
            }
        }
        .padding(.horizontal, 28)
    }
    
}


