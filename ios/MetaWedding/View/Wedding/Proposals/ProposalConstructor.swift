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
            
            TextField("", text: $globalViewModel.partnerAddress)
                .font(Font.headline.weight(.bold))
                .placeholder(when: globalViewModel.partnerAddress.isEmpty) {
                    Text("Partner address")
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
                .disabled(globalViewModel.isProposalActionPending)
                .padding(.horizontal, 16)
                .padding(.top, 16)
            
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
                .disabled(globalViewModel.isProposalActionPending)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .onReceive(Just(globalViewModel.name)) { _ in
                    if globalViewModel.name.count > globalViewModel.nameLimit {
                        globalViewModel.name = String(globalViewModel.name.prefix(globalViewModel.nameLimit))
                    }
                }
            
            if globalViewModel.isProposalActionPending {
                WeddingProgress()
                    .padding(.top, 20)
            } else {
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
                .padding(.top, 44)
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
