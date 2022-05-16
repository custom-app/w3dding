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
                                    if proposal.receiverAccepted, let meta = proposal.meta {
                                        VStack(spacing: 0) {
                                            Spacer()
                                            
                                            Button {
                                                if let url = URL(string: meta.httpImageLink()), UIApplication.shared.canOpenURL(url) {
                                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                                } else {
                                                    //TODO: show error alert
                                                }
                                            } label: {
                                                HStack(spacing: 0) {
                                                    VStack(alignment: .leading, spacing: 0) {
                                                        Text("Marriage license")
                                                            .font(.headline)
                                                            .fontWeight(.bold)
                                                            .foregroundColor(Colors.darkPurple)
                                                    }
                                                    .padding(.leading, 20)
                                                    
                                                    Spacer()
                                                    
                                                    Image("ic_file")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 24)
                                                        .padding(.trailing, 20)
                                                        .padding(.leading, 16)
                                                }
                                                .padding(.vertical, 16)
                                                .background(Color.white.opacity(0.5))
                                                .cornerRadius(10)
                                            }
                                            .padding(.top, 32)
                                            .padding(.horizontal, 16)
                                            
                                            if proposal.meta != nil {
                                                Button {
                                                    globalViewModel.confirmProposal(to: proposal.address, metaUrl: proposal.metaUrl)
                                                } label: {
                                                    Text("Confirm")
                                                        .font(.system(size: 17))
                                                        .fontWeight(.bold)
                                                        .foregroundColor(.white)
                                                        .padding(.horizontal, 32)
                                                        .padding(.vertical, 16)
                                                        .background(Colors.purple)
                                                        .cornerRadius(32)
                                                }
                                                .padding(.top, 24)
                                            }
                                            Spacer()
                                        }
                                        .frame(height: geometry.size.height - (headerShown ? 100 : 0))
                                    } else {
                                        VStack(spacing: 0) {
                                            
                                            HStack {
                                                Spacer()
                                                
                                                ZStack(alignment: .leading) {
                                                    ZStack {
                                                        if let image = proposal.receiverImage {
                                                            Image(uiImage: image)
                                                                .resizable()
                                                                .scaledToFill()
                                                                .frame(width: 150, height: 150)
                                                                .clipped()
                                                        } else {
                                                            Image("ic_heart_secondary")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: 80)
                                                                .padding(.top, 10)
                                                        }
                                                    }
                                                    .frame(width: 150, height: 150)
                                                    .cornerRadius(150)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 150)
                                                            .stroke(Colors.darkPurple, lineWidth: 6)
                                                    )
                                                    .padding(.leading, 100)
                                                    
                                                    ZStack {
                                                        if let image = proposal.authorImage {
                                                            Image(uiImage: image)
                                                                .resizable()
                                                                .scaledToFill()
                                                                .frame(width: 150, height: 150)
                                                                .clipped()
                                                        } else {
                                                            Image("ic_heart")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: 80)
                                                                .padding(.top, 10)
                                                        }
                                                    }
                                                    .frame(width: 150, height: 150)
                                                    .background(Colors.mainBackground)
                                                    .cornerRadius(150)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 150)
                                                            .stroke(Colors.darkPurple, lineWidth: 6)
                                                    )
                                                }
                                                
                                                Spacer()
                                            }
                                            
                                            Text("Proposal sent to")
                                                .font(.title3.weight(.bold))
                                                .foregroundColor(Colors.darkPurple.opacity(0.65))
                                                .padding(.top, 16)
                                            
                                            HStack {
                                                Spacer()
                                                Text("Address: \(proposal.address)")
                                                    .font(.system(size: 13).weight(.regular))
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
                                                Spacer()
                                            }
                                            .padding(.horizontal, 28)
                                            .padding(.top, 16)
                                            
                                            Text("Please wait for the partner decision")
                                                .font(.subheadline.weight(.bold))
                                                .foregroundColor(Colors.darkPurple.opacity(0.65))
                                                .padding(.top, 16)
                                            
                                        }
                                        .frame(height: geometry.size.height - (headerShown ? 100 : 0))
                                    }
                                }
                            } else {
                                VStack(spacing: 8) {
                                    ForEach(globalViewModel.authoredProposals) { proposal in
                                        VStack(alignment: .leading, spacing: 0) {
                                            
                                            Text(proposal.meta?.properties.secondPersonName ?? "")
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
                                                    UIPasteboard.general.string =
                                                    globalViewModel.authoredProposals.first?.address ?? ""
                                                } label: {
                                                    Image("ic_copy")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 20)
                                                }
                                                .padding(.trailing, 80)
                                            }
                                        }
                                        .padding(16)
                                        .background(Color.white.opacity(0.5))
                                        .cornerRadius(10)
                                        .padding(.horizontal, 16)
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
            }
        }

    }
}

struct NewProposalBar: View {
    
    @EnvironmentObject
    var globalViewModel: GlobalViewModel
    
    @Binding
    var showSheet: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Something wrong with your proposal?")
                .font(Font.subheadline.weight(.bold))
                .foregroundColor(Colors.darkGrey)
            
            Button {
                showSheet = true
            } label: {
                Text("New proposal")
                    .font(Font.subheadline.weight(.bold))
                    .foregroundColor(Colors.purple)
            }
            .padding(.top, 10)
            .sheet(isPresented: $showSheet,
                  onDismiss: { showSheet = false }) {
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


