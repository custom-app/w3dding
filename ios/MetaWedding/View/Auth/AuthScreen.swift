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
            VStack(spacing: 0) {
                
                HStack {
                    Text("Wallet")
                        .foregroundColor(Colors.darkPurple)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.leading, 16)
                .padding(.top, 18)
                
                if globalViewModel.isConnecting || globalViewModel.isReconnecting {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.2)
                    Spacer()
                } else {
                    VStack(spacing: 0) {
                        if let session = globalViewModel.session {
                            if globalViewModel.isWrongChain {
                                WrongChainScreen()
                            } else {
                                ConnectedScreen()
                            }
                        } else {
                            NotConnectedScreen()
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
