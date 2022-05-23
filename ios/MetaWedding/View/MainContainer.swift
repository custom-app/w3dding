//
//  MainContainer.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 03.04.2022.
//

import SwiftUI

struct MainContainer: View {
    
    static let AUTH_TAB_TAG = 1
    static let WEDDING_TAB_TAG = 2
    
    @EnvironmentObject
    var globalViewModel: GlobalViewModel
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Image("DefaultBackground")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                
                ZStack {
                    if globalViewModel.onAuthTab {
                        AuthScreen()
                            .navigationTitle("")
                            .navigationBarHidden(true)
                    } else {
                        WeddingContainer()
                            .navigationTitle("")
                            .navigationBarHidden(true)
                    }
                }
                .padding(.bottom, 140)
                .sheet(isPresented: $globalViewModel.showConnectSheet) {
                    ConnectSheet()
                        .environmentObject(globalViewModel)
                }
                
                VStack(alignment: .center, spacing: 0) {
                    Spacer()
                    BottomMenu(firstTabSelected: $globalViewModel.onAuthTab)
                        .padding(.bottom, 80)
                }
            }
        }
        .alert(item: $globalViewModel.alert) { alert in
            alert.alert()
        }
    }
}

struct BottomMenu: View {
    
    @Binding
    var firstTabSelected: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            if firstTabSelected {
                ZStack {
                    Image("ic_wallet_on")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24)
                }
                .frame(width: 78, height: 46)
                .background(Color.white)
                .cornerRadius(50)
                .padding(.leading, 2)
                .padding(.vertical, 2)
                
                ZStack {
                    Image("ic_marriage_off")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24)
                        .padding(.trailing, 29)
                        .padding(.leading, 24)
                }
                .frame(width: 77)
                .onTapGesture {
                    withAnimation {
                        firstTabSelected = false
                    }
                }
            } else {
                ZStack {
                    Image("ic_wallet_off")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24)
                        .padding(.leading, 29)
                        .padding(.trailing, 24)
                }
                .frame(width: 77)
                .onTapGesture {
                    withAnimation {
                        firstTabSelected = true
                    }
                }
                
                ZStack {
                    Image("ic_marriage_on")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24)
                }
                .frame(width: 78, height: 46)
                .background(Color.white)
                .cornerRadius(50)
                .padding(.trailing, 2)
                .padding(.vertical, 2)
            }
        }
        .frame(width: 157, height: 50)
        .background(Color.white.opacity(0.5))
        .cornerRadius(30)
    }
}

struct MainContainer_Previews: PreviewProvider {
    static var previews: some View {
        MainContainer()
    }
}
