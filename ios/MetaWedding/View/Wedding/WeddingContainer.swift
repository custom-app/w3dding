//
//  WeddingScreen.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 03.04.2022.
//

import SwiftUI

struct WeddingContainer: View {
    
    @EnvironmentObject
    var globalViewModel: GlobalViewModel
    
    @StateObject
    var weddingViewModel = WeddingViewModel()
    
    var body: some View {
        ScrollView(.vertical) {
            PullToRefreshView(bg: .black, fg: .white) {
                globalViewModel.refresh()
            }
            VStack {
                if globalViewModel.isConnecting || globalViewModel.isReconnecting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.2)
                } else {
                    if globalViewModel.session != nil {
                        if globalViewModel.isWrongChain {
                            Text("Error occured while loading data")
                                .padding(.horizontal, 20)
                                .multilineTextAlignment(.center)
                        } else if globalViewModel.allLoaded {
                            if globalViewModel.marriage != nil {
                                MarriageScreen()
                            } else {
                                ProposalsScreen()
                            }
                        } else if globalViewModel.isErrorLoading {
                            Text("Connected to wrong chain. Please disconnect and connect to Polygon")
                                .padding(.horizontal, 20)
                                .padding(.top, 50)
                                .multilineTextAlignment(.center)
                            
                            Button {
                                globalViewModel.refresh()
                            } label: {
                                Text("Retry")
                                    .padding(16)
                                    .background(Color.white)
                                    .cornerRadius(8)
                            }
                            .padding(.top, 20)
                        } else {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1.2)
                        }
                    } else {
                        Text("Not connected")
                    }
                }
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .environmentObject(weddingViewModel)
    }
}

struct WeddingScreen_Previews: PreviewProvider {
    static var previews: some View {
        WeddingContainer()
    }
}
