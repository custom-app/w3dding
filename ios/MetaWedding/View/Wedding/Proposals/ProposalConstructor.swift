//
//  ProposalConstructor.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 10.04.2022.
//

import SwiftUI
import Combine
import PhotosUI

struct ProposalConstructor: View {
    
    @State
    var showPhotoPicker = false
    
    @EnvironmentObject
    var globalViewModel: GlobalViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Make proposal")
                .font(Font.title2.weight(.bold))
                .foregroundColor(Colors.darkPurple)
                .multilineTextAlignment(.center)
            
            Text("Choose your avatar")
                .font(Font.title3.weight(.bold))
                .foregroundColor(Colors.darkPurple.opacity(0.65))
                .multilineTextAlignment(.center)
                .padding(.top, 24)
            
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
                            .frame(width: 180, height: 180)
                            .clipped()
                    } else {
                        Image("ic_heart")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 96)
                            .padding(.top, 10)
                    }
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image("ic_edit")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 27)
                                .padding(.top, 4)
                                .padding(.bottom, 3)
                            Spacer()
                        }
                        .background(Colors.purple)
                    }
                }
                .frame(width: 180, height: 180)
                .cornerRadius(150)
                .overlay(
                    RoundedRectangle(cornerRadius: 150)
                        .stroke(Colors.purple, lineWidth: 6)
                )
            }
            .disabled(globalViewModel.isProposalActionPending)
            .padding(.top, 16)
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
            
            TextField("", text: $globalViewModel.partnerAddress)
                .font(Font.headline.weight(.bold))
                .placeholder(when: globalViewModel.partnerAddress.isEmpty) {
                    HStack {
                        Spacer()
                        Text("Partner address")
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
                .padding(.top, 16)
            
            if globalViewModel.isProposalActionPending {
                WeddingProgress()
                    .padding(.top, 20)
            } else {
                Button {
                    guard Tools.isAddressValid(globalViewModel.partnerAddress) else {
                        globalViewModel.alert = IdentifiableAlert.build(
                            id: "validation failed",
                            title: "Validation Failed",
                            message: "Entered address is not valid. Please enter correct polygon address"
                        )
                        return
                    }
                    guard !globalViewModel.name.isEmpty else {
                        globalViewModel.alert = IdentifiableAlert.build(
                            id: "validation failed",
                            title: "Validation Failed",
                            message: "Name can't be empty"
                        )
                        return
                    }
                    hideKeyboard()
                    globalViewModel.sendNewProposal(
                        selfAddress: globalViewModel.walletAccount!,
                        partnerAddress: globalViewModel.partnerAddress,
                        selfName: globalViewModel.name,
                        selfImage: globalViewModel.selfImage)
                } label: {
                    Text("Propose")
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
            
            if globalViewModel.isProposalActionPending {
                Text("It can take some time. Please wait and don't close the app")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Colors.darkPurple)
                    .multilineTextAlignment(.center)
                    .padding(.top, 22)
                    .padding(.horizontal, 20)
            }
        }
    }
}

struct ProposalConstructor_Previews: PreviewProvider {
    static var previews: some View {
        ProposalConstructor()
    }
}
