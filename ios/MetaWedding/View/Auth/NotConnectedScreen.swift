//
//  NotConnectedScreen.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 23.04.2022.
//

import SwiftUI

struct NotConnectedScreen: View {
    
    @EnvironmentObject
    var globalViewModel: GlobalViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Spacer()
            
            Image("ic_warning")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundColor(Colors.darkPurple.opacity(0.65))
                .frame(width: 48)
            
            Text("Wallet not connected")
                .font(.system(size: 22))
                .fontWeight(.bold)
                .foregroundColor(Colors.darkPurple)
                .padding(.top, 24)
            
            Button {
                globalViewModel.showConnectSheet = true
            } label: {
                Text("Connect")
                    .font(.system(size: 17))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 15)
                    .background(Colors.purple)
                    .cornerRadius(32)
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
                .foregroundColor(Colors.darkPurple.opacity(0.65))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 56)
                .padding(.bottom, 52)
        }
        .padding(.top, 50)
        .sheet(isPresented: $globalViewModel.showConnectSheet) {
            ConnectSheet()
                .environmentObject(globalViewModel)
        }
    }
}

struct NotConnectedScreen_Previews: PreviewProvider {
    static var previews: some View {
        NotConnectedScreen()
    }
}
