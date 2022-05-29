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
            
            VStack(alignment: .leading, spacing: 0) {
                Text("Connected to \(globalViewModel.walletName)")
                    .font(.system(size: 15))
                    .fontWeight(.bold)
                    .foregroundColor(Colors.darkPurple)
                
                HStack {
                    Text("Address: \(globalViewModel.walletAccount ?? "")")
                        .font(.system(size: 12))
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
                            .frame(width: 20, height: 20)
                    }
                }
                .padding(.top, 12)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(10)
            .padding(.horizontal, 16)
            .padding(.top, 28)
            
            Button {
                globalViewModel.disconnect()
            } label: {
                HStack {
                    Text("Disconnect")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Colors.purple)
                    Spacer()
                }
            }
            .padding(.top, 16)
            .padding(.horizontal, 32)
            
            
            if let balance = globalViewModel.balance, balance == 0 {
                GeometryReader { innerGeometry in
                    ScrollView(showsIndicators: false) {
                        PullToRefreshView(bg: .black.opacity(0), fg: .black) {
                            globalViewModel.requestBalance()
                        }
                        VStack(spacing: 0) {
                            Image("ic_attention")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Colors.darkPurple.opacity(0.65))
                                .frame(height: 48)
                                .padding(.top, 40)
                            
                            Text("We can gift you some Matics to pay for a transaction fee once")
                                .font(.system(size: 22))
                                .fontWeight(.bold)
                                .foregroundColor(Colors.darkPurple.opacity(0.65))
                                .multilineTextAlignment(.center)
                                .padding(.top, 24)
                            
                            if globalViewModel.faucetRequested {
                                Text("It should take a few seconds. Please refresh the status by swipe down")
                                    .font(.system(size: 18))
                                    .fontWeight(.bold)
                                    .foregroundColor(Colors.darkPurple.opacity(0.65))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 28)
                            } else {
                                Button {
                                    globalViewModel.callFaucet()
                                } label: {
                                    Text("Get Matics")
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
                                .padding(.top, 24)
                            }
                            Text("Love is a game that two can play\nand both win")
                                .font(Font.custom("marediv", size: 17))
                                .multilineTextAlignment(.center)
                                .overlay (
                                    LinearGradient(
                                        colors: [Color(hex: "#F600FB"), Color(hex: "#BD00FF")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    .mask(
                                        Text("Love is a game that two can play\nand both win")
                                            .font(Font.custom("marediv", size: 17))
                                            .multilineTextAlignment(.center)
                                    )
                                )
                                .padding(.horizontal, 20)
                                .padding(.top, 50)
                            Spacer()
                        }
                        .frame(height: innerGeometry.size.height)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
            } else {
                VStack(spacing: 0) {
                    Image("ic_accept")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Colors.darkPurple.opacity(0.65))
                        .frame(width: 54)
                    
                    Text("You are ready to get started")
                        .font(.system(size: 22))
                        .fontWeight(.bold)
                        .foregroundColor(Colors.darkPurple.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .padding(.top, 24)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 50)
                
                Spacer()
                Text("Love is a game that two can play\nand both win")
                    .font(Font.custom("marediv", size: 17))
                    .multilineTextAlignment(.center)
                    .overlay (
                        LinearGradient(
                            colors: [Color(hex: "#F600FB"), Color(hex: "#BD00FF")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .mask(
                            Text("Love is a game that two can play\nand both win")
                                .font(Font.custom("marediv", size: 17))
                                .multilineTextAlignment(.center)
                        )
                    )
                    .padding(.horizontal, 30)
                Spacer()
            }
            
            Button {
                withAnimation {
                    globalViewModel.showingOnboarding = true
                }
            } label: {
                Text("Tutorial")
                    .font(.system(size: 17))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 38)
                    .padding(.vertical, 16)
                    .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#B20CFC"), Color(hex: "#6E01F0")]),
                                               startPoint: .leading,
                                               endPoint: .trailing))
                    .cornerRadius(32)
            }
            .padding(.bottom, 40)
        }
    }
}

struct ConnectedScreen_Previews: PreviewProvider {
    static var previews: some View {
        ConnectedScreen()
    }
}
