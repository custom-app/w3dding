//
//  ConnectedScreen.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 24.04.2022.
//

import SwiftUI

struct ConnectedScreen: View {
    
    @EnvironmentObject
    var globalViewModel: GlobalViewModel
    
    var body: some View {
        
        VStack(spacing: 0) {
            Spacer()
            
            Image("ic_accept")
                .resizable()
                .scaledToFit()
                .frame(width: 54)
                .padding(.top, 80)
            
            Text("Connected to \(globalViewModel.walletName)")
                .font(.system(size: 22))
                .fontWeight(.bold)
                .foregroundColor(Colors.darkPurple)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.top, 20)
            
            HStack {
                Spacer()
                Text("Address: \(globalViewModel.walletAccount ?? "")")
                    .font(.system(size: 13))
                    .fontWeight(.regular)
                    .foregroundColor(Colors.darkPurple)
                    .lineLimit(1)
                    .truncationMode(.middle)
                
                Button {
                    UIPasteboard.general.string = globalViewModel.walletAccount ?? ""
                } label: {
                    Image("ic_copy")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                }
                Spacer()
            }
            .padding(.horizontal, 28)
            .padding(.top, 24)
            
            Button {
                globalViewModel.disconnect()
            } label: {
                Text("Disconnect")
                    .font(.system(size: 17))
                    .fontWeight(.bold)
                    .foregroundColor(Colors.purple)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 15)
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(Colors.purple, lineWidth: 2)
                    )
            }
            .padding(.top, 70)
            
            if let balance = globalViewModel.balance, balance == 0 {
            
                if globalViewModel.faucetRequested {
                    Text("It should take a few seconds. Please refresh the status by swipe down")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                } else {
                    Button {
                        globalViewModel.callFaucet()
                    } label: {
                        Text("Faucet")
                            .font(.system(size: 17))
                            .fontWeight(.bold)
                            .foregroundColor(Colors.purple)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 15)
                            .background(Color.white.opacity(0.5))
                            .cornerRadius(32)
                            .overlay(
                                RoundedRectangle(cornerRadius: 32)
                                    .stroke(Colors.purple, lineWidth: 2)
                            )
                    }
                    .padding(.top, 20)
                }
                
                
            }
            
            Spacer()
        }
    }
}

struct ConnectedScreen_Previews: PreviewProvider {
    static var previews: some View {
        ConnectedScreen()
    }
}
