//
//  ConnectScreen.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 24.04.2022.
//

import SwiftUI

struct ConnectSheet: View {
    
    @EnvironmentObject
    var globalViewModel: GlobalViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
//                Image("DefaultBackground")
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Colors.darkPurple.opacity(0.3))
                        .frame(width: 64, height: 6)
                        .cornerRadius(20)
                        .padding(.top, 8)
                    
                    Text("Connect to wallet")
                        .foregroundColor(Colors.darkPurple)
                        .font(.system(size: 34))
                        .fontWeight(.bold)
                        .padding(.top, 8)
                    
                    Spacer()
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 18) {
                            ForEach(Wallets.All, id: \.self) { wallet in
                                Button {
                                    globalViewModel.connect(wallet: wallet)
                                } label: {
                                    HStack {
                                        Spacer()
                                        Text(wallet.name)
                                            .font(.system(size: 17))
                                            .fontWeight(.bold)
                                            .foregroundColor(Colors.purple)
                                        Spacer()
                                    }
                                    .padding(.vertical, 15)
                                    .background(Color.white)
                                    .cornerRadius(32)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 32)
                                            .stroke(Colors.purple, lineWidth: 2)
                                    )
                                }
                                .padding(.horizontal, 30)
                            }
                        }
                        .padding(.top, 14)
                    }
                    
                    Spacer()
                    
                    Image("ic_polygon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 46)
                        .padding(.bottom, 16)
                    
                    Text("Please select a wallet connected to the Polygon Blockchain")
                        .font(.system(size: 15))
                        .fontWeight(.bold)
                        .foregroundColor(Colors.darkPurple.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 56)
                        .padding(.bottom, 18)
                    
                    Text("*Make sure you have the latest version of the wallet app you are using")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Colors.darkPurple.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 26)
                        .padding(.bottom, 12)
                    
                    Button {
                         globalViewModel.showConnectSheet = false
                     } label: {
                         Text("Skip for now")
                             .font(.system(size: 15))
                             .fontWeight(.bold)
                             .foregroundColor(Colors.purple)
                             .multilineTextAlignment(.center)
                             .padding(.horizontal, 56)
                             .padding(.bottom, 12)
                     }
                }
                .frame(width: geometry.size.width)
            }
        }
        .background(Color.white.ignoresSafeArea())
    }
}

struct ConnectScreen_Previews: PreviewProvider {
    static var previews: some View {
        ConnectSheet()
    }
}
