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
        VStack {
            if let session = globalViewModel.session {
                
                Text("Connected to \(session.walletInfo?.peerMeta.name ?? "???")")
                
                Button {
                    globalViewModel.disconnect()
                } label: {
                    Text("Disconnect")
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(8)
                }
            } else {
                Button {
                    globalViewModel.connect()
                } label: {
                    Text("Connect")
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(8)
                }
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
