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
    
    let geometry: GeometryProxy
    
    var body: some View {
        VStack(spacing: 0) {
            if globalViewModel.isAuthoredProposalsLoaded {
                if globalViewModel.authoredProposals.isEmpty {

                    Text("You are single")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Colors.darkGrey)
                        .padding(.top, 40)
                    
                    ProposalConstructor()
                        .padding(.top, 12)
                } else {
                    if globalViewModel.authoredProposals.count == 1 {
                        GeometryReader { innerGeometry in
                            VStack(spacing: 0) {
                                Text("Proposal sent to")
                                    .font(.title3.weight(.bold))
                                    .foregroundColor(Colors.darkGrey)
                                
                                Text(globalViewModel.authoredProposals.first?.meta?.properties.secondPersonName ?? "")
                                    .font(Font.title2.weight(.bold))
                                    .foregroundColor(Colors.darkPurple)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 24)
                                
                                HStack {
                                    Spacer()
                                    Text("Address: \(globalViewModel.authoredProposals.first?.address ?? "")")
                                        .font(.system(size: 13).weight(.regular))
                                        .fontWeight(.regular)
                                        .foregroundColor(Colors.darkPurple)
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                    
                                    Button {
                                        UIPasteboard.general.string =
                                        globalViewModel.authoredProposals.first?.address ?? ""
                                    } label: {
                                        Image("ic_copy")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20)
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, 28)
                                .padding(.top, 8)
                            }
                            .padding(.bottom, 20)
                            .frame(width: innerGeometry.size.width, height: innerGeometry.size.height)
                        }
                        
                        VStack(spacing:0) {
                            
                            Text("Something wrong with your proposal?")
                                .font(Font.subheadline.weight(.bold))
                                .foregroundColor(Colors.darkGrey)
                            
                            Button {
                                showConstructor = true
                            } label: {
                                Text("New proposal")
                                    .font(Font.subheadline.weight(.bold))
                                    .foregroundColor(Colors.purple)
                            }
                            .padding(.top, 10)
                            .sheet(isPresented: $showConstructor,
                                  onDismiss: { showConstructor = false }) {
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
                        .padding(.bottom, 26)
                        .padding(.horizontal, 28)
                    } else {
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
                                .environmentObject(globalViewModel)
                        }
                    }
                }
            }
        }
        .frame(width: geometry.size.width, height: geometry.size.height)

    }
}
