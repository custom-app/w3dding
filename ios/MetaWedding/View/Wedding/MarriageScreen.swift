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
                
                if let address = globalViewModel.walletAccount {
                    let isAuthor = address == marriage.authorAddress
                    if marriage.divorceState == .notRequested {
                        Button {
                            globalViewModel.requestDivorce()
                        } label: {
                            Text("Divorce")
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(8)
                        }
                        .padding(.top, 40)
                    } else {
                        if (isAuthor && marriage.divorceState == .requestedByReceiver) ||
                            (!isAuthor && marriage.divorceState == .requestedByAuthor) {
                            Button {
                                globalViewModel.confirmDivorce()
                            } label: {
                                Text("Confirm divorce")
                                    .padding(16)
                                    .background(Color.white)
                                    .cornerRadius(8)
                            }
                            .padding(.top, 40)
                        } else if (isAuthor && marriage.divorceState == .requestedByAuthor) ||
                                    (!isAuthor && marriage.divorceState == .requestedByReceiver) {
                            let curTime = Int64((Date().timeIntervalSince1970).rounded())
                            if curTime > marriage.divorceRequestTimestamp + marriage.divorceTimeout {
                                Button {
                                    globalViewModel.confirmDivorce()
                                } label: {
                                    Text("Divorce 1-way")
                                        .padding(16)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                }
                                .padding(.top, 40)
                            } else {
                                Text("Divorce in progress")
                                    .padding(.top, 50)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct MarriageScreen_Previews: PreviewProvider {
    static var previews: some View {
        MarriageScreen()
    }
}
