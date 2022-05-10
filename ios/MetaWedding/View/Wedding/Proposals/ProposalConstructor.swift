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
    
    let nameLimit = 50
    
    @State
    var showPhotoPicker = false
    
    @EnvironmentObject
    var globalViewModel: GlobalViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            if let address = globalViewModel.walletAccount {
                
                Text("Make proposal")
                    .font(Font.title2.weight(.bold))
                    .foregroundColor(Colors.darkPurple)
                    .multilineTextAlignment(.center)
                TextField("Your address", text: .constant(address))
                    .font(Font.headline.weight(.bold))
                    .foregroundColor(Colors.darkGrey)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 13)
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(32)
                    .disabled(true)
                    .padding(.horizontal, 16)
                    .padding(.top, 40)
                
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
                    .disabled(globalViewModel.isNewProposalPending)
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
                    .disabled(globalViewModel.isNewProposalPending)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .onReceive(Just(globalViewModel.name)) { _ in
                        if globalViewModel.name.count > nameLimit {
                            globalViewModel.name = String(globalViewModel.name.prefix(nameLimit))
                        }
                    }

                
                Button {
                    openPhotoPicker()
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
                .padding(.top, 44)
                
                if globalViewModel.isNewProposalPending {
                    WeddingProgress()
                        .padding(.top, 20)
                } else {
                    Button {
                        guard Tools.isAddressValid(globalViewModel.partnerAddress) else {
                            globalViewModel.alert = IdentifiableAlert.build(
                                id: "validation failed",
                                title: "Validation Failed",
                                message: "Entered address is not valid"
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
                            selfImage: globalViewModel.selfImage,
                            templateId: globalViewModel.templateId)
//                        globalViewModel.buildCertificateWebView()
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
                
//                if globalViewModel.sendTxPending {
//                    Text("Please check wallet app for verification. If there is no verification popup try to click button again")
//                        .padding(.horizontal, 20)
//                        .multilineTextAlignment(.center)
//                        .padding(.top, 10)
//                }
                
                if globalViewModel.isNewProposalPending {
                    Text("It can take some time. Please wait and don't close the app")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Colors.darkPurple)
                        .multilineTextAlignment(.center)
                        .padding(.top, 22)
                        .padding(.horizontal, 20)
                }
                
                if globalViewModel.showWebView {
                    WebView(htmlString: globalViewModel.certificateHtml) { formatter in
                        globalViewModel.showWebView = false
//                        globalViewModel.uploadCertificateToIpfs(formatter: formatter)
                    }
                    .frame(minHeight: 1, maxHeight: 1)
                    .opacity(0)
                }
                
                if let image = globalViewModel.selfImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 140)
                        .padding(.top, 20)
                }
            }
        }
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
    }
    
    func openPhotoPicker() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .limited:
            showPhotoPicker = true
        case .denied, .restricted:
            globalViewModel.alert = IdentifiableAlert.build(
                id: "photo library access",
                title: "Access denied",
                message: "You need to give permission for photos in settings"
            )
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                if newStatus == .authorized {
                    showPhotoPicker = true
                }
            }
        @unknown default:
            print("Unknown photo library authorization status")
        }
    }
}

struct ProposalConstructor_Previews: PreviewProvider {
    static var previews: some View {
        ProposalConstructor()
    }
}
