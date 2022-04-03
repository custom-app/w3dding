//
//  ContentView.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 28.03.2022.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject
    var globalViewModel = GlobalViewModel()
    
    var body: some View {
        NavigationView {
            MainContainer()
                .navigationTitle("")
                .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .environmentObject(globalViewModel)
        .onAppear {
            print("content view on appear")
            globalViewModel.initWalletConnect()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
