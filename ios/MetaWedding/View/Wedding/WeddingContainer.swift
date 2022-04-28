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
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                HStack(alignment: .bottom) {
                    Text("Wedding")
                        .foregroundColor(Colors.darkPurple)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    if !globalViewModel.marriage.isEmpty() &&
                        globalViewModel.marriage.divorceState == .notRequested {
                        
                        Button {
                            globalViewModel.requestDivorce()
                        } label: {
                            Text("Divorce")
                                .foregroundColor(Colors.redAction)
                                .font(.subheadline)
                                .fontWeight(.bold)
                        }
                        .padding(.bottom, 8)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 18)
                
                if globalViewModel.isConnecting || globalViewModel.isReconnecting {
                    Spacer()
                    WeddingProgress()
                    Spacer()
                } else {
                    if globalViewModel.session != nil {
                        if globalViewModel.isWrongChain {
                            WrongChainScreen()
                        } else if globalViewModel.allLoaded {
                            Spacer()
                            GeometryReader { innerGeometry in
                                ScrollView(showsIndicators: false) {
                                    PullToRefreshView(bg: .black.opacity(0), fg: .black) {
                                        globalViewModel.refresh()
                                    }
                                    if globalViewModel.marriage.isEmpty() {
                                        ProposalsScreen(geometry: innerGeometry)
                                    } else {
                                        MarriageScreen()
                                            .padding(.top, 30)
                                    }
                                }
                            }
                            Spacer()
                        } else if globalViewModel.isErrorLoading {
                            Text("Error occured while loading data")
                                .padding(.horizontal, 20)
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
                            Spacer()
                            WeddingProgress()
                            Spacer()
                        }
                    } else {
                        NotConnectedScreen()
                    }
                }
            }
            .frame(width: geometry.size.width)
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

struct WeddingScreen_Previews: PreviewProvider {
    static var previews: some View {
        WeddingContainer()
    }
}
