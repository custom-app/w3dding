//
//  ReceivedProposalPending.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 16.05.2022.
//

import SwiftUI
import Combine

struct ReceivedProposalPending: View {
    
    @EnvironmentObject
    var globalViewModel: GlobalViewModel
    
    var proposal: Proposal
    
    @State
    var showTemplatePicker = false
    
    @State
    var showPhotoPicker = false
    
    @State
    var showPreview = false
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Text("Received proposal from")
                    .font(.title3.weight(.bold))
                    .foregroundColor(Colors.darkPurple.opacity(0.65))
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                
                Text(proposal.meta?.properties.firstPersonName ?? "")
                    .font(Font.title2.weight(.bold))
                    .foregroundColor(Colors.darkPurple)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    .padding(.horizontal, 20)
                
                HStack {
                    Spacer()
                    Text("\(proposal.address)")
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
                .padding(.horizontal, 48)
                .padding(.top, 8)
            }
            
            Text("Choose your avatar")
                .font(Font.title3.weight(.bold))
                .foregroundColor(Colors.darkPurple.opacity(0.65))
                .multilineTextAlignment(.center)
                .padding(.top, 20)
            
            HStack {
                Spacer()
                
                ZStack(alignment: .leading) {
                    ZStack {
                        if let image = proposal.authorImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipped()
                        } else {
                            Image("ic_heart_secondary")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 53)
                                .padding(.top, 5)
                        }
                    }
                    .frame(width: 100, height: 100)
                    .background(Colors.mainBackground)
                    .cornerRadius(150)
                    .overlay(
                        RoundedRectangle(cornerRadius: 150)
                            .stroke(Colors.darkPurple, lineWidth: 6)
                    )
                    .padding(.leading, 50)
                    
                    Button {
                        globalViewModel.openPhotoPicker {
                            showPhotoPicker = true
                        }
                    } label: {
                        ZStack {
                            if let image = globalViewModel.selfImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipped()
                            } else {
                                Image("ic_heart")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 53)
                                    .padding(.top, 5)
                            }
                            
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Image("ic_edit")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 18)
                                        .padding(.top, 3)
                                        .padding(.bottom, 4)
                                    Spacer()
                                }
                                .background(Colors.purple)
                            }
                        }
                        .frame(width: 100, height: 100)
                        .background(Colors.mainBackground)
                        .cornerRadius(150)
                        .overlay(
                            RoundedRectangle(cornerRadius: 150)
                                .stroke(Colors.purple, lineWidth: 6)
                        )
                    }
                    .disabled(globalViewModel.isProposalActionPending)
                    .sheet(isPresented: $showPhotoPicker) {
                        PhotoPicker { image in
                            print("image picked")
                            showPhotoPicker = false
                            guard let image = image else {
                                print("image nil")
                                withAnimation {
                                    globalViewModel.selfImage = nil
                                }
                                return
                            }
                            globalViewModel.handleSelfPhotoPicked(photo: image)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.top, 16)
            
            TextField("", text: $globalViewModel.name)
                .font(Font.headline.weight(.bold))
                .placeholder(when: globalViewModel.name.isEmpty) {
                    HStack {
                        Spacer()
                        Text("Your name")
                            .font(Font.headline.weight(.bold))
                            .foregroundColor(Colors.darkPurple.opacity(0.65))
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                }
                .foregroundColor(Colors.darkPurple)
                .lineLimit(1)
                .truncationMode(.tail)
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
                .background(Color.white.opacity(0.5))
                .cornerRadius(32)
                .disabled(globalViewModel.isProposalActionPending)
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .onReceive(Just(globalViewModel.name)) { _ in
                    if globalViewModel.name.count > globalViewModel.nameLimit {
                        globalViewModel.name = String(globalViewModel.name.prefix(globalViewModel.nameLimit))
                    }
                }
            
            
            if globalViewModel.isProposalActionPending {
                WeddingProgress()
                    .padding(.top, 20)
            } else {
                HStack(spacing:0) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Picked Template:")
                            .font(.system(size: 17))
                            .foregroundColor(Colors.darkPurple)
                        
                        Text("\(globalViewModel.selectedTemplate.name)")
                            .font(.system(size: 20).weight(.bold))
                            .foregroundColor(Colors.darkPurple)
                            .padding(.top, 8)
                    }
                    Spacer()
                    ZStack(alignment: .bottomTrailing) {
                        Image("preview_cert\(globalViewModel.selectedTemplate.id)")
                            .resizable()
                            .scaledToFit()
                        
                        Image("ic_edit")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12)
                            .padding(.top, 3)
                            .padding(.bottom, 3)
                            .padding(.leading, 3)
                            .padding(.trailing, 1)
                            .background(Colors.purple)
                            .cornerRadius(14, corners: [.topLeft])
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Colors.purple, lineWidth: 2)
                    )
                    .frame(width: 90)
                    .onTapGesture {
                        showTemplatePicker = true
                    }
                }
                .sheet(isPresented: $showTemplatePicker) {
                    TemplatePicker(showPicker: $showTemplatePicker)
                        .environmentObject(globalViewModel)
                }
                .padding(16)
                .background(Color.white.opacity(0.5))
                .cornerRadius(20)
                .padding(.horizontal, 16)
                .padding(.top, 16)

                
                if proposal.meta != nil {
                    HStack(spacing: 0) {
                        Spacer()

                        if !globalViewModel.name.isEmpty {
                            Button {
                                globalViewModel.openPhotoPicker {
                                    showPreview = true
                                }
                            } label: {
                                Text("Preview")
                                    .font(.system(size: 17))
                                    .fontWeight(.bold)
                                    .foregroundColor(Colors.purple)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 15)
                                    .background(Color.white.opacity(0.5))
                                    .cornerRadius(32)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 32)
                                            .stroke(Colors.purple, lineWidth: 2)
                                    )
                            }
                            .sheet(isPresented: $showPreview, onDismiss: {
                                globalViewModel.previewImage = nil
                            }) {
                                PreviewSheet(proposal: $globalViewModel.receivedProposals[0])
                                    .environmentObject(globalViewModel)
                            }
                            .padding(.trailing, 30)
                        }

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
                        Spacer()
                    }
                    .padding(.top, 24)
                }
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
                                                                firstPersonImage: properties.firstPersonImage,
                                                                blockNumber: "\(proposal.prevBlockNumber+1)",
                                                                templateId: globalViewModel.selectedTemplate.id)
                    }
                    .frame(minHeight: 1, maxHeight: 1)
                    .opacity(0)
                }
            }
            
            if globalViewModel.isProposalActionPending {
                Text("It can take some time. Please wait and don't close the app")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Colors.darkPurple)
                    .multilineTextAlignment(.center)
                    .padding(.top, 22)
                    .padding(.horizontal, 20)
            }
            
            Spacer()
        }
    }
}
