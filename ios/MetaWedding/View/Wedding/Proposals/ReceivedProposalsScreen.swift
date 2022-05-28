//
//  ReceivedProposalsScreen.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 10.04.2022.
//

import SwiftUI
import Combine

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
                    if let proposal = globalViewModel.receivedProposals.first {
                        if proposal.receiverAccepted {
                            ReceivedProposalAccepted(proposal: proposal)
                                .frame(height: geometry.size.height-100)
                        } else {
                            ReceivedProposalPending(proposal: proposal)
                                .frame(height: geometry.size.height-100)
                        }
                    }
                } else {
                    ForEach(globalViewModel.receivedProposals) { proposal in
                        HStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(proposal.meta?.properties.firstPersonName ?? "")
                                    .font(Font.headline.weight(.bold))
                                    .foregroundColor(Colors.darkPurple)
                                    .padding(.top, 8)
                                
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
                                
                                Text(proposal.receiverAccepted ? "Waiting for partner reply" : "Waiting for your reply")
                                    .font(Font.headline.weight(.bold))
                                    .foregroundColor(Colors.darkPurple.opacity(0.65))
                                    .padding(.top, 8)
                            }
                            
                            Spacer()
                            
                            ZStack(alignment: .leading) {
                                ZStack {
                                    if let image = proposal.authorImage {
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
                                    if proposal.receiverAccepted {
                                        if let image = proposal.receiverImage {
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
                                    } else if let image = globalViewModel.selfImage {
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
                        .padding(16)
                        .background(Color.white.opacity(0.5))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .onTapGesture {
                            selectedProposal = proposal
                        }
                    }
                    .sheet(item: $selectedProposal,
                           onDismiss: { selectedProposal = nil }) { proposal in
                        ReceivedProposalInfo(proposal: proposal)
                            .environmentObject(globalViewModel)
                    }
                }
            }
        }
        .frame(width: geometry.size.width)
    }
}

struct PreviewSheet: View {
    
    @EnvironmentObject
    var globalViewModel: GlobalViewModel
    
    @Binding
    var proposal: Proposal
    
    var body: some View {
        ZStack {
            Image("DefaultBackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                if let image = globalViewModel.previewImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                } else {
                    WeddingProgress()
                    Text("Loading preview")
                        .font(Font.headline.bold())
                        .foregroundColor(Colors.darkPurple)
                        .padding(.top, 24)
                    
                    if globalViewModel.showPreviewWebView {
                        WebView(htmlString: globalViewModel.previewHtml) { formatter in
                            print("webview callback")
                            globalViewModel.showPreviewWebView = false
                            globalViewModel.generatePreviewImage(formatter: formatter)
                        }
                        .frame(minHeight: 1, maxHeight: 1)
                        .opacity(0)
                    }
                }
                Spacer()
            }
        }
        .onAppear {
            globalViewModel.previewImage = nil
            if let properties = proposal.meta?.properties {
                globalViewModel.buildPreview(properties: properties,
                                             name: globalViewModel.name,
                                             image: globalViewModel.selfImage,
                                             templateId: globalViewModel.selectedTemplate.id)
            }
        }
    }
}
