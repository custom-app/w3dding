//
//  MainScreen.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 28.03.2022.
//

import SwiftUI

struct MainScreen: View {
    
    @EnvironmentObject
    var globalViewModel: GlobalViewModel
    
    var body: some View {
        VStack {
            Button {
                globalViewModel.connect()
            } label: {
                Text("Connect")
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(8)
            }
        }
        .sheet(item: $globalViewModel.session,
               onDismiss: { globalViewModel.session = nil }) { session in
            ActionsSheet()
                .environmentObject(globalViewModel)
        }
    }
}

struct ActionsSheet: View {
    
    @EnvironmentObject
    var globalViewModel: GlobalViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            Button {
                globalViewModel.personalSign()
            } label: {
                Text("Personal Sign")
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(8)
            }
            Button {
                globalViewModel.sendTx()
            } label: {
                Text("Send tx")
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(8)
            }
            Button {
                globalViewModel.disconnect()
            } label: {
                Text("Disconnect")
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(8)
            }
        }
    }
}

struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
    }
}
