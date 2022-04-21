//
//  ProposalConstructor.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 10.04.2022.
//

import SwiftUI

struct ProposalConstructor: View {
    
    @EnvironmentObject
    var globalViewModel: GlobalViewModel
    
    var body: some View {
        VStack {
            if let address = globalViewModel.walletAccount {
                Text("Your address")
                    .font(.system(size: 15))
                    .padding(.horizontal, 20)
                    .multilineTextAlignment(.center)
                
                TextField("Your address", text: .constant(address))
                    .foregroundColor(.white)
                    .font(.system(size: 15))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(6)
                    .disabled(true)
                    .padding(.horizontal, 20)
                
                Text("Partner address")
                    .font(.system(size: 15))
                    .padding(.horizontal, 20)
                    .multilineTextAlignment(.center)
                
                TextField("Partner address", text: $globalViewModel.partnerAddress)
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(6)
                    .disabled(false)
                    .padding(.horizontal, 20)
                
                Text("Your name")
                    .font(.system(size: 15))
                    .padding(.horizontal, 20)
                    .multilineTextAlignment(.center)
                
                TextField("Your name", text: $globalViewModel.name)
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(6)
                    .disabled(false)
                    .padding(.horizontal, 20)
                
                Text("Partner name")
                    .font(.system(size: 15))
                    .padding(.horizontal, 20)
                    .multilineTextAlignment(.center)
                
                TextField("Partner name", text: $globalViewModel.partnerName)
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(6)
                    .disabled(false)
                    .padding(.horizontal, 20)
                
                
                
                VStack(spacing: 30) {
                    
                    Button {
                        guard Tools.isAddressValid(globalViewModel.partnerAddress) else {
                            globalViewModel.alert = IdentifiableAlert.build(
                                id: "validation failed",
                                title: "Validation Failed",
                                message: "Entered address is no valid"
                            )
                            return
                        }
                        guard !globalViewModel.name.isEmpty && !globalViewModel.partnerName.isEmpty else {
                            globalViewModel.alert = IdentifiableAlert.build(
                                id: "validation failed",
                                title: "Validation Failed",
                                message: "Names can't be empty"
                            )
                            return
                        }
                        globalViewModel.buildCertificateWebView()
                    } label: {
                        Text("Propose")
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                    
                    if globalViewModel.sendTxPending {
                        Text("Please check wallet app for verification. If there is no verification popup try to click button again")
                            .padding(.horizontal, 20)
                            .multilineTextAlignment(.center)
                    }
                    
                    if globalViewModel.showWebView {
                        WebView(htmlString: globalViewModel.certificateHtml) { formatter in
                            globalViewModel.showWebView = false
                            globalViewModel.uploadCertificateToNftStorage(formatter: formatter)
                        }
                        .frame(minHeight: 1, maxHeight: 1)
                        .opacity(0)
                    }
                }
                .padding(.top, 20)
            }
        }
    }
}

struct ProposalConstructor_Previews: PreviewProvider {
    static var previews: some View {
        ProposalConstructor()
    }
}
