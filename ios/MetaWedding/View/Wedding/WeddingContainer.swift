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
                    Text("Agreement")
                        .foregroundColor(Colors.darkPurple)
                        .font(.system(size: 26))
                        .fontWeight(.bold)
                    Spacer()
                    if globalViewModel.session != nil &&
                        !globalViewModel.marriage.isEmpty() &&
                        globalViewModel.marriage.divorceState == .notRequested {
                        
                        Button {
                            globalViewModel.requestDivorce()
                        } label: {
                            Text("Divorce")
                                .foregroundColor(Colors.redAction)
                                .font(.system(size: 15))
                                .fontWeight(.bold)
                        }
                        .padding(.bottom, 8)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 18)
                
                if globalViewModel.isConnecting || globalViewModel.isReconnecting {
                    Spacer()
                    VStack(spacing: 0) {
                        WeddingProgress()
                        Text("Connecting")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(Colors.darkPurple)
                            .padding(.top, 24)
                    }
                    Spacer()
                } else {
                    if globalViewModel.session != nil || globalViewModel.connectedAddress != nil {
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
                            if globalViewModel.isAuthoredProposalsLoaded &&
                                globalViewModel.authoredProposals.count > 0 &&
                                globalViewModel.selectedMyProposals {
                                NewProposalBar()
                                    .padding(.bottom, 12)
                                    .padding(.top, 18)
                            }
                            Spacer()
                        } else if globalViewModel.isErrorLoading {
                            Spacer()
                
                            Text("Error occured while loading data")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(Colors.darkPurple)
                                .padding(.horizontal, 20)
                                .multilineTextAlignment(.center)
                            
                            Button {
                                globalViewModel.refresh()
                            } label: {
                                Text("Retry")
                                    .font(.system(size: 17))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 15)
                                    .background(Colors.purple)
                                    .cornerRadius(32)
                            }
                            .padding(.top, 20)
                            
                            Spacer()
                        } else {
                            Spacer()
                            VStack(spacing: 0) {
                                WeddingProgress()
                                Text("Loading data")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(Colors.darkPurple)
                                    .padding(.top, 24)
                            }
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
