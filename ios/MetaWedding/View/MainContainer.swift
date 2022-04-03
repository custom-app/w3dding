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
            ZStack(alignment: .bottomLeading) {
                TabView(selection: $globalViewModel.selectedTab) {
                    AuthScreen()
                        .navigationTitle("")
                        .navigationBarHidden(true)
                        .tabItem({
                            Image(systemName: "person.crop.circle").renderingMode(.template)
                            Text("Auth")
                        })
                        .tag(MainContainer.AUTH_TAB_TAG)

                    WeddingScreen()
                        .navigationTitle("")
                        .navigationBarHidden(true)
                        .tabItem({
                            Image(systemName: "shippingbox").renderingMode(.template)
                            Text("Wedding")
                        })
                        .tag(MainContainer.WEDDING_TAB_TAG)
                }
//                .accentColor(Color.white)
            }
        }
    }
}

struct MainContainer_Previews: PreviewProvider {
    static var previews: some View {
        MainContainer()
    }
}
