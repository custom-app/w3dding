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
                VStack {
                    if let session = globalViewModel.session {

                        Text("Connected to \(session.walletInfo?.peerMeta.name ?? "???")")
                            .padding(.bottom, 10)
                        
                        Text("Account: \n\(session.walletInfo?.accounts[0] ?? "???")")
                            .multilineTextAlignment(.center)
                            .font(.system(size: 16))
                            .padding(.bottom, 20)

                        Button {
                            globalViewModel.disconnect()
                        } label: {
                            Text("Disconnect")
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(8)
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
