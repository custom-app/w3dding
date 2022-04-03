//
//  WeddingScreen.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 03.04.2022.
//

import SwiftUI

struct WeddingScreen: View {
    
    @EnvironmentObject
    var globalViewModel: GlobalViewModel
    
    var body: some View {
        VStack {
            if globalViewModel.session != nil {
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
                }
            } else {
                Text("Not connected")
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

struct WeddingScreen_Previews: PreviewProvider {
    static var previews: some View {
        WeddingScreen()
    }
}
