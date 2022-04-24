//
//  WrongChainScreen.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 24.04.2022.
//

import SwiftUI

struct WrongChainScreen: View {
    
    @EnvironmentObject
    var globalViewModel: GlobalViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Spacer()
            
            Image("ic_warning")
                .resizable()
                .scaledToFit()
                .frame(width: 48)
            
            Text("Wrong blockchain")
                .font(.system(size: 22))
                .fontWeight(.bold)
                .foregroundColor(Colors.darkPurple)
                .padding(.top, 24)
            
            Text("Please change blockchain / reconnect wallet")
                .font(.system(size: 13))
                .fontWeight(.regular)
                .foregroundColor(Colors.darkPurple)
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
            .padding(.top, 24)
            
            Spacer()
            
            Image("ic_polygon")
                .resizable()
                .scaledToFit()
                .frame(width: 46)
                .padding(.bottom, 24)
            
            Text("Please select a wallet connected to the Polygon Blockchain")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(Colors.darkGrey)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 56)
                .padding(.bottom, 52)
        }
        .padding(.top, 50)
    }
}

struct WrongChainScreen_Previews: PreviewProvider {
    static var previews: some View {
        WrongChainScreen()
    }
}
