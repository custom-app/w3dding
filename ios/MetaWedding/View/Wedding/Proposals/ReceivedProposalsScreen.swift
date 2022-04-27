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
        VStack(spacing: 0) {
            if globalViewModel.isReceivedProposalsLoaded {
                if globalViewModel.receivedProposals.isEmpty {
                    Text("There are no proposals addressed to you")
                        .font(Font.title2.weight(.bold))
                        .foregroundColor(Colors.darkPurple)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 36)
                } else if globalViewModel.receivedProposals.count == 1 {
                    
                    Spacer()
                    
                    Text("Received proposal from")
                        .font(.title3.weight(.bold))
                        .foregroundColor(Colors.darkGrey)
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    
                    Text(globalViewModel.receivedProposals.first?.meta?.properties.firstPersonName ?? "")
                        .font(Font.title2.weight(.bold))
                        .foregroundColor(Colors.darkPurple)
                        .multilineTextAlignment(.center)
                        .padding(.top, 24)
                        .padding(.horizontal, 20)
                    
                    HStack {
                        Spacer()
                        Text("Address: \(globalViewModel.receivedProposals.first?.address ?? "")")
                            .font(.system(size: 13).weight(.regular))
                            .fontWeight(.regular)
                            .foregroundColor(Colors.darkPurple)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        
                        Button {
                            UIPasteboard.general.string =
                            globalViewModel.receivedProposals.first?.address ?? ""
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
                    
                    
                    Button {
                        globalViewModel
                            .acceptProposition(to: globalViewModel.receivedProposals.first!.address,
                                               metaUrl: globalViewModel.receivedProposals.first!.metaUrl)
                    } label: {
                        Image("ic_accept")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Colors.purple)
                            .frame(width: 48)
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                    
                    if let meta = globalViewModel.receivedProposals.first?.meta {
                        VStack(spacing: 0) {
                            Text("You will be listed in certificate as")
                                .font(Font.subheadline.weight(.bold))
                                .foregroundColor(Colors.darkGrey)
                            
                            Text(meta.properties.secondPersonName)
                                .font(Font.title3.weight(.bold))
                                .foregroundColor(Colors.darkPurple)
                                .padding(.top, 8)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                    
                } else {
                    ForEach(globalViewModel.receivedProposals) { proposal in
                        VStack(alignment: .leading, spacing: 0) {
                            Text(proposal.meta?.properties.firstPersonName ?? "")
                                .font(Font.headline.weight(.bold))
                                .foregroundColor(Colors.darkPurple)
                            
                            Rectangle()
                                .fill(Color.white)
                                .frame(height: 1)
                                .padding(.vertical, 8)
                            
                            HStack {
                                Text("Address: \(proposal.address)")
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
                            
                            HStack {
                                Spacer()
                                Button {
                                    globalViewModel.acceptProposition(to: proposal.address,
                                                                      metaUrl: proposal.metaUrl)
                                } label: {
                                    Image("ic_accept")
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(Colors.purple)
                                        .frame(width: 28)
                                }
                            }
                            .padding(.top, 8)
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.5))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
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
