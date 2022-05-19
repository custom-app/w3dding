//
//  AuthoredProposalAccepted.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 19.05.2022.
//

import SwiftUI

struct AuthoredProposalAccepted: View {
    
    @EnvironmentObject
    var globalViewModel: GlobalViewModel
    
    var proposal: Proposal
    
    var body: some View {
        if let meta = proposal.meta {
            VStack(spacing: 0) {
                Spacer()
                
                Button {
                    if let url = URL(string: meta.httpImageLink()), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        //TODO: show error alert
                    }
                } label: {
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Marriage license")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(Colors.darkPurple)
                        }
                        .padding(.leading, 20)
                        
                        Spacer()
                        
                        Image("ic_file")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24)
                            .padding(.trailing, 20)
                            .padding(.leading, 16)
                    }
                    .padding(.vertical, 16)
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(10)
                }
                .padding(.top, 32)
                .padding(.horizontal, 16)
                
                if proposal.meta != nil {
                    Button {
                        globalViewModel.confirmProposal(to: proposal.address, metaUrl: proposal.metaUrl)
                    } label: {
                        Text("Confirm")
                            .font(.system(size: 17))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .background(Colors.purple)
                            .cornerRadius(32)
                    }
                    .padding(.top, 24)
                }
                Spacer()
            }
        }
    }
}
