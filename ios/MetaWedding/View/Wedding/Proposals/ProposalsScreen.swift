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
            
            ProposalsMenu()
                .padding(.top, 14)
                .padding(.leading, 16)
            
            GeometryReader { innerGeometry in
                if globalViewModel.selectedMyProposals {
                    if globalViewModel.allAuthoredProposalsInfoLoaded {
                        AuthoredProposalsScreen(geometry: innerGeometry)
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.2)
                    }
                } else {
                    if globalViewModel.allReceivedProposalsInfoLoaded {
                        ReceivedProposalsScreen(geometry: innerGeometry)
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.2)
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
                Button {
                    withAnimation {
                        globalViewModel.selectedMyProposals = true
                    }
                } label: {
                    Text("My proposals")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(globalViewModel.selectedMyProposals ?
                                         Colors.darkPurple : Colors.grey)
                        .padding(.vertical, 15)
                        .padding(.horizontal, 12)
                        .background(Color.white.opacity(globalViewModel.selectedMyProposals ? 1 : 0))
                        .cornerRadius(50)
                }
                .disabled(globalViewModel.selectedMyProposals)
                .padding(5)
                
                Button {
                    withAnimation {
                        globalViewModel.selectedMyProposals = false
                    }
                } label: {
                    Text("Proposals for me")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(globalViewModel.selectedMyProposals ?
                                         Colors.grey : Colors.darkPurple)
                        .padding(.vertical, 15)
                        .padding(.horizontal, 12)
                        .background(Color.white.opacity(globalViewModel.selectedMyProposals ? 0 : 1))
                        .cornerRadius(50)
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
