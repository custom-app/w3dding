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
    
    @State
    var showPhotoPicker = false
    
    @State
    var showTemplatePicker = false
    
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
                            VStack(spacing: 0) {
                                Spacer()
                                
                                Text("Received proposal from")
                                    .font(.title3.weight(.bold))
                                    .foregroundColor(Colors.darkGrey)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 24)
                                
                                Text(proposal.meta?.properties.firstPersonName ?? "")
                                    .font(Font.title2.weight(.bold))
                                    .foregroundColor(Colors.darkPurple)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 24)
                                    .padding(.horizontal, 20)
                                
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
                                .padding(.top, 8)
                                
                                Text("Waiting for your partner confirmation")
                                    .font(Font.title2.weight(.bold))
                                    .foregroundColor(Colors.darkPurple)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 40)
                                    .padding(.horizontal, 20)
                                
                                Spacer()
                                
                            }.frame(height: geometry.size.height-100)
                        } else {
                            VStack(spacing: 0) {
                                Spacer()
                                
                                Text("Received proposal from")
                                    .font(.title3.weight(.bold))
                                    .foregroundColor(Colors.darkGrey)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 24)
                                
                                Text(proposal.meta?.properties.firstPersonName ?? "")
                                    .font(Font.title2.weight(.bold))
                                    .foregroundColor(Colors.darkPurple)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 24)
                                    .padding(.horizontal, 20)
                                
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
                                .padding(.top, 8)
                                
                                TextField("", text: $globalViewModel.name)
                                    .font(Font.headline.weight(.bold))
                                    .placeholder(when: globalViewModel.name.isEmpty) {
                                        Text("Your name")
                                            .font(Font.headline.weight(.bold))
                                            .foregroundColor(Colors.darkGrey.opacity(0.5))
                                            .multilineTextAlignment(.center)
                                    }
                                    .foregroundColor(Colors.darkGrey)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 13)
                                    .background(Color.white.opacity(0.5))
                                    .cornerRadius(32)
                                    .disabled(globalViewModel.isNewProposalPending)
                                    .padding(.horizontal, 16)
                                    .padding(.top, 16)
                                    .onReceive(Just(globalViewModel.name)) { _ in
                                        if globalViewModel.name.count > globalViewModel.nameLimit {
                                            globalViewModel.name = String(globalViewModel.name.prefix(globalViewModel.nameLimit))
                                        }
                                    }
                                
                                Button {
                                    globalViewModel.openPhotoPicker {
                                        showPhotoPicker = true
                                    }
                                } label: {
                                    Text("Pick photo")
                                        .font(.system(size: 17))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 32)
                                        .padding(.vertical, 16)
                                        .background(Colors.purple)
                                        .cornerRadius(32)
                                }
                                .padding(.top, 24)
                                .sheet(isPresented: $showPhotoPicker) {
                                    PhotoPicker { image in
                                        print("image picked")
                                        showPhotoPicker = false
                                        guard let image = image else {
                                            globalViewModel.alert = IdentifiableAlert.build(
                                                id: "loading photo err",
                                                title: "An error has occurred",
                                                message: "Image loading failed. Please try again"
                                            )
                                            return
                                        }
                                        globalViewModel.handleSelfPhotoPicked(photo: image)
                                    }
                                }
                                
                                VStack {
                                    HStack {
                                        Text("Picked template:")
                                            .font(.system(size: 17))
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)
                                        Spacer()
                                        Image("preview_cert\(globalViewModel.selectedTemplateId)")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100)
                                            .onTapGesture {
                                                showTemplatePicker = true
                                            }
                                    }
                                    .sheet(isPresented: $showTemplatePicker) {
                                        TemplatePicker(showPicker: $showTemplatePicker)
                                            .environmentObject(globalViewModel)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 10)
                                
                                
                                if globalViewModel.isAcceptPending {
                                    WeddingProgress()
                                        .padding(.top, 20)
                                } else {
                                    Button {
                                        guard !globalViewModel.name.isEmpty else {
                                            globalViewModel.alert = IdentifiableAlert.build(
                                                id: "validation failed",
                                                title: "Validation Failed",
                                                message: "Name can't be empty"
                                            )
                                            return
                                        }
                                        if let properties = proposal.meta?.properties {
                                            globalViewModel.generateCerificateAndAcceptProposition(proposal: proposal,
                                                                                                   properties: properties,
                                                                                                   name: globalViewModel.name,
                                                                                                   image: globalViewModel.selfImage)
                                        }
                                    } label: {
                                        Text("Accept")
                                            .font(.system(size: 17))
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 32)
                                            .padding(.vertical, 16)
                                            .background(Colors.purple)
                                            .cornerRadius(32)
                                    }
                                    .padding(.top, 40)
                                }
                                
                                if globalViewModel.showWebView {
                                    if let address = globalViewModel.walletAccount,
                                       let properties = proposal.meta?.properties {
                                        WebView(htmlString: globalViewModel.certificateHtml) { formatter in
                                            globalViewModel.showWebView = false
                                            globalViewModel.uploadCertificateToIpfs(formatter: formatter,
                                                                                    id: String(proposal.tokenId),
                                                                                    firstPersonName: properties.firstPersonName,
                                                                                    secondPersonName: globalViewModel.name,
                                                                                    firstPersonAddress: properties.firstPersonAddress,
                                                                                    secondPersonAddress: address,
                                                                                    templateId: globalViewModel.selectedTemplateId,
                                                                                    blockHash: globalViewModel.currentBlockHash)
                                        }
                                        .frame(minHeight: 1, maxHeight: 1)
                                        .opacity(0)
                                    }
                                }
                                
                                if globalViewModel.isAcceptPending {
                                    Text("It can take some time. Please wait and don't close the app")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(Colors.darkPurple)
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 22)
                                        .padding(.horizontal, 20)
                                }
                                
        //                        Spacer()
                                
                                
                            }.frame(height: geometry.size.height-100)
                        }
                        
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
                        .padding(.vertical, 5)
                    }
                }
            }
        }
        .frame(width: geometry.size.width)
        .sheet(item: $selectedProposal,
               onDismiss: { selectedProposal = nil }) { proposal in
            ReceivedProposalInfo(proposal: proposal)
                .environmentObject(globalViewModel)
        }
    }
}
