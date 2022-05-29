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
                
                Text("Congratulations!")
                    .font(.system(size: 20, weight: .bold))
                    .fontWeight(.bold)
                    .foregroundColor(Colors.darkPurple)
                    .padding(.top, 24)
                
                Text("Your partner applied the proposal")
                    .font(.system(size: 20, weight: .bold))
                    .fontWeight(.bold)
                    .foregroundColor(Colors.darkPurple.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    .padding(.horizontal, 20)
                
                Text("We are ready to register your Metawedding")
                    .font(.system(size: 17, weight: .bold))
                    .fontWeight(.bold)
                    .foregroundColor(Colors.darkPurple.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    .padding(.horizontal, 16)
                
                Button {
                    if let url = URL(string: meta.httpImageLink()), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        //TODO: show error alert
                    }
                } label: {
                    ZStack(alignment: .topTrailing) {
                        if let image = proposal.certImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                            
                            Image("ic_scale")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 24)
                                .padding(.trailing, 11)
                                .padding(.top, 10)
                        } else {
                            VStack(spacing: 0) {
                                HStack {
                                    Spacer()
                                    WeddingProgress()
                                    Spacer()
                                }
                                Text("Loading certificate")
                                    .font(.system(size: 17, weight: .bold))
                                    .fontWeight(.bold)
                                    .foregroundColor(Colors.darkPurple)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 8)
                                    .padding(.horizontal, 20)
                            }
                            .padding(.vertical, 50)
                            .background(Color.white)
                            .cornerRadius(20)
                        }
                    }
                    .padding(15)
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(20)
                }
                .padding(.top, 16)
                .padding(.horizontal, 16)
                
                if proposal.meta != nil {
                    Button {
                        globalViewModel.confirmProposal(to: proposal.address, metaUrl: proposal.metaUrl)
                    } label: {
                        Text("MINT!")
                            .font(.system(size: 17))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 44)
                            .padding(.vertical, 18)
                            .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#B20CFC"), Color(hex: "#6E01F0")]),
                                                       startPoint: .leading,
                                                       endPoint: .trailing))
                            .cornerRadius(32)
                    }
                    .padding(.top, 24)
                }
                
                Text("The best thing in our life is Love")
                    .font(Font.custom("marediv", size: 17))
                    .multilineTextAlignment(.center)
                    .overlay (
                        LinearGradient(
                            colors: [Color(hex: "#F600FB"), Color(hex: "#BD00FF")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .mask(
                            Text("The best thing in our life is Love")
                                .font(Font.custom("marediv", size: 17))
                                .multilineTextAlignment(.center)
                        )
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                Spacer()
            }
        }
    }
}
