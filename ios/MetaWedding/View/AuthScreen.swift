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
            ScrollView {
                ZStack {
                    if globalViewModel.isConnecting || globalViewModel.isReconnecting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.2)
                    } else {
                        VStack {
                            if let session = globalViewModel.session {

                                Text("Connected to \(session.walletInfo?.peerMeta.name ?? "???")")
                                    .padding(.bottom, 10)
                                
                                Text("Address:")
                                    .font(.system(size: 15))
                                Text("\(session.walletInfo?.accounts[0] ?? "???")")
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 15))
                                    .padding(.bottom, 20)

                                Button {
                                    globalViewModel.disconnect()
                                } label: {
                                    Text("Disconnect")
                                        .padding(16)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                }
                                if globalViewModel.isWrongChain {
                                    Text("Connected to wrong chain. Please disconnect and connect to Polygon")
                                        .padding(.horizontal, 20)
                                        .padding(.top, 30)
                                        .multilineTextAlignment(.center)
                                }
                            } else {
                                Text("Connect to:")
                                    .padding(.bottom, 10)
                                    .padding(.top, 20)
                                List {
                                    ForEach(Wallets.All, id: \.self) { wallet in
                                        Button {
                                            globalViewModel.connect(wallet: wallet)
                                        } label: {
                                            HStack {
                                                Spacer()
                                                Text(wallet.name)
                                                Spacer()
                                            }
                                        }
                                    }
                                }
                                Text("Make sure you are connecting to Polygon chain")
                                    .padding(.bottom, 30)
                            }
                        }
                    }
                }
                .frame(width: geometry.size.width)
                .frame(minHeight: geometry.size.height)
            }
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
