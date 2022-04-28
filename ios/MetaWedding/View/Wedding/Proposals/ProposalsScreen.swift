//
//  ProposalsScreen.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 10.04.2022.
//

import SwiftUI

struct ProposalsScreen: View {
    
    @EnvironmentObject
    var globalViewModel: GlobalViewModel
    
    let geometry: GeometryProxy
    
    var body: some View {
        VStack {
            
            if globalViewModel.isReceivedProposalsLoaded &&
                !globalViewModel.receivedProposals.isEmpty {
                ProposalsMenu()
                    .padding(.top, 14)
                    .padding(.leading, 16)
            }
            
            GeometryReader { innerGeometry in
                if globalViewModel.selectedMyProposals {
                    if globalViewModel.isAuthoredProposalsLoaded {
                        AuthoredProposalsScreen(geometry: innerGeometry)
                    } else {
                        Spacer()
                        WeddingProgress()
                        Spacer()
                    }
                } else {
                    if globalViewModel.isReceivedProposalsLoaded {
                        ReceivedProposalsScreen(geometry: innerGeometry)
                    } else {
                        Spacer()
                        WeddingProgress()
                        Spacer()
                    }
                }
            }
        }
        .frame(height: geometry.size.height)
    }
}

struct ProposalsMenu: View {
    
    @EnvironmentObject
    var globalViewModel: GlobalViewModel
    
    var body: some View {
        HStack {
            HStack(spacing: 0) {
                Text("My proposals")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(globalViewModel.selectedMyProposals ?
                                     Colors.darkPurple : Colors.grey)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 12)
                    .background(Color.white.opacity(globalViewModel.selectedMyProposals ? 1 : 0))
                    .cornerRadius(50)
                    .onTapGesture {
                        withAnimation {
                            globalViewModel.selectedMyProposals = true
                        }
                    }
                    .disabled(globalViewModel.selectedMyProposals)
                    .padding(5)
                
                Text("Proposals for me")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(globalViewModel.selectedMyProposals ?
                                     Colors.grey : Colors.darkPurple)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 12)
                    .background(Color.white.opacity(globalViewModel.selectedMyProposals ? 0 : 1))
                    .cornerRadius(50)
                    .onTapGesture {
                        withAnimation {
                            globalViewModel.selectedMyProposals = false
                        }
                    }
                    .disabled(!globalViewModel.selectedMyProposals)
                    .padding(.leading, 7)
                    .padding(.vertical, 5)
                    .padding(.trailing, 5)
            }
            .background(Color.white.opacity(0.5))
            .cornerRadius(30)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.white, lineWidth: 1)
            )
            
            Spacer()
        }
    }
}
