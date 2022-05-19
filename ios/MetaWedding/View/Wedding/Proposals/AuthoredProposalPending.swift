//
//  AuthoredProposalPending.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 19.05.2022.
//

import SwiftUI

struct AuthoredProposalPending: View {
    
    var proposal: Proposal
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                ZStack(alignment: .leading) {
                    ZStack {
                        if let image = proposal.receiverImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .clipped()
                        } else {
                            Image("ic_heart_secondary")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80)
                                .padding(.top, 10)
                        }
                    }
                    .frame(width: 150, height: 150)
                    .cornerRadius(150)
                    .overlay(
                        RoundedRectangle(cornerRadius: 150)
                            .stroke(Colors.darkPurple, lineWidth: 6)
                    )
                    .padding(.leading, 100)
                    
                    ZStack {
                        if let image = proposal.authorImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .clipped()
                        } else {
                            Image("ic_heart")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80)
                                .padding(.top, 10)
                        }
                    }
                    .frame(width: 150, height: 150)
                    .background(Colors.mainBackground)
                    .cornerRadius(150)
                    .overlay(
                        RoundedRectangle(cornerRadius: 150)
                            .stroke(Colors.darkPurple, lineWidth: 6)
                    )
                }
                
                Spacer()
            }
            
            Text("Proposal sent to")
                .font(.title3.weight(.bold))
                .foregroundColor(Colors.darkPurple.opacity(0.65))
                .padding(.top, 16)
            
            HStack {
                Spacer()
                Text("Address: \(proposal.address)")
                    .font(.system(size: 13).weight(.regular))
                    .fontWeight(.regular)
                    .foregroundColor(Colors.darkPurple)
                    .lineLimit(1)
                    .truncationMode(.middle)
                
                Button {
                    UIPasteboard.general.string = proposal.address
                } label: {
                    Image("ic_copy")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                }
                Spacer()
            }
            .padding(.horizontal, 28)
            .padding(.top, 16)
            
            Text("Please wait for the partner decision")
                .font(.subheadline.weight(.bold))
                .foregroundColor(Colors.darkPurple.opacity(0.65))
                .padding(.top, 16)
            
        }
    }
}
