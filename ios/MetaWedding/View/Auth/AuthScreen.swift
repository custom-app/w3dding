//
//  MainScreen.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 28.03.2022.
//

import SwiftUI

struct AuthScreen: View {
    
    @EnvironmentObject
    var globalViewModel: GlobalViewModel
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Text("Wallet")
                    .foregroundColor(Colors.darkPurple)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.leading, 16)
            .padding(.top, 18)
            VStack(spacing: 0) {
                if globalViewModel.isConnecting || globalViewModel.isReconnecting {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.2)
                    Spacer()
                } else {
                    VStack(spacing: 0) {
                        if let session = globalViewModel.session {

                            Text("Connected to \(session.walletInfo?.peerMeta.name ?? "???")")
                                .padding(.bottom, 10)
                            
                            Text("Address:")
                                .font(.system(size: 15))
                            Text("\(session.walletInfo?.accounts[0] ?? "???")")
                                .multilineTextAlignment(.center)
                                .font(.system(size: 15))
                            
                            if let balance = globalViewModel.balance {
                                Text("Balance: \(balance) MATIC")
                                    .font(.system(size: 17))
                                    .padding(.top, 20)
                            }

                            Button {
                                globalViewModel.disconnect()
                            } label: {
                                Text("Disconnect")
                                    .padding(16)
                                    .background(Color.white)
                                    .cornerRadius(8)
                            }
                            .padding(.top, 20)
                            if globalViewModel.isWrongChain {
                                Text("Connected to wrong chain. Please disconnect and connect to Polygon")
                                    .padding(.horizontal, 20)
                                    .padding(.top, 30)
                                    .multilineTextAlignment(.center)
                            }
                        } else {
                            NotConnectedScreen()
                                .padding(.top, 50)
                        }
                    }
                }
            }
            .frame(width: geometry.size.width)
//            .frame(height: geometry.size.height)
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        AuthScreen()
    }
}
