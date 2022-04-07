//
//  WeddingScreen.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 03.04.2022.
//

import SwiftUI

struct WeddingScreen: View {
    
    @EnvironmentObject
    var globalViewModel: GlobalViewModel
    
    var body: some View {
        VStack {
            if globalViewModel.isConnecting || globalViewModel.isReconnecting {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.2)
            } else {
                if globalViewModel.session != nil {
                    if globalViewModel.isWrongChain {
                        Text("Connected to wrong chain. Please disconnect and connect to Polygon")
                            .padding(.horizontal, 20)
                            .multilineTextAlignment(.center)
                    } else if let address = globalViewModel.walletAccount {
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
                                globalViewModel.personalSign()
                            } label: {
                                Text("Personal Sign")
                                    .padding(16)
                                    .background(Color.white)
                                    .cornerRadius(8)
                            }
                            
                            Button {
                                globalViewModel.sendTx()
                            } label: {
                                Text("Send tx")
                                    .padding(16)
                                    .background(Color.white)
                                    .cornerRadius(8)
                            }
                            
                            if globalViewModel.sendTxPending {
                                Text("Please check wallet app for verification. If there is no verification popup try to click button again")
                                    .padding(.horizontal, 20)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.top, 20)
                    }
                } else {
                    Text("Not connected")
                }
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

struct WeddingScreen_Previews: PreviewProvider {
    static var previews: some View {
        WeddingScreen()
    }
}
