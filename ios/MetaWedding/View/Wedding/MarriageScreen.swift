//
//  MarriageScreen.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 09.04.2022.
//

import SwiftUI

struct MarriageScreen: View {
    
    @EnvironmentObject
    var globalViewModel: GlobalViewModel
    
    var body: some View {
        VStack {
            Text("Marriage Screen")
                .padding(.bottom, 20)
            
            if let marriage = globalViewModel.marriage {
                Text(marriage.authorAddress)
                    .font(.system(size: 14))
                Text("+")
                    .font(.system(size: 24))
                    .padding(.vertical, 2)
                Text(marriage.receiverAddress)
                    .font(.system(size: 14))
                
                Button {
                    globalViewModel.sendTx()
                } label: {
                    Text("Divorce")
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(8)
                }
                .padding(.top, 40)
            }
        }
    }
}

struct MarriageScreen_Previews: PreviewProvider {
    static var previews: some View {
        MarriageScreen()
    }
}
