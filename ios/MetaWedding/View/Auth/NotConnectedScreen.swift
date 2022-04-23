//
//  NotConnectedScreen.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 23.04.2022.
//

import SwiftUI

struct NotConnectedScreen: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Spacer()
            
            Image("ic_warning")
                .resizable()
                .scaledToFit()
                .frame(width: 48)
            
            Text("Wallet not connected")
                .font(.system(size: 22))
                .fontWeight(.bold)
                .foregroundColor(Colors.darkPurple)
                .padding(.top, 24)
            
            Button {
                
            } label: {
                Text("Connect")
                    .font(.system(size: 17))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 17)
                    .background(Colors.purple)
                    .cornerRadius(32)
            }
            .padding(.top, 24)
            .padding(.bottom, 24)
            
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
                .padding(.horizontal, 50)
                .padding(.bottom, 44)
        }
    }
}

struct NotConnectedScreen_Previews: PreviewProvider {
    static var previews: some View {
        NotConnectedScreen()
    }
}
