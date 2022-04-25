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
        VStack(spacing: 0) {
            let marriage = globalViewModel.marriage
            if globalViewModel.isErrorLoadingMeta {
                //TODO: retry block here
            } else if let meta = globalViewModel.meta, !marriage.isEmpty() {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        PersonCardInfo(name: meta.properties.firstPersonName,
                                       address: meta.properties.firstPersonAddress)
                        
                        Text("in wedlock with")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.vertical, 18)
                        
                        PersonCardInfo(name: meta.properties.secondPersonName,
                                       address: meta.properties.secondPersonAddress)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 30)
                }
                .background(
                    Image("MarriageCard")
                    .resizable()
                    .scaledToFill()
                )
                .cornerRadius(32)
                .padding(.horizontal, 16)
                
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
                            
                            Rectangle()
                                .fill(Color.white)
                                .frame(height: 1)
                                .padding(.vertical, 12)
                            
                            Text("Date: **\(Date(timestamp: Int64(marriage.timestamp)).formattedDateString("dd.MM.yyyy"))**")
                                .font(.subheadline)
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
            }
            if let meta = globalViewModel.meta, !marriage.isEmpty() {
                
                if let address = globalViewModel.walletAccount {
                    let isAuthor = address == marriage.authorAddress
                    if marriage.divorceState == .notRequested {
                        Button {
                            globalViewModel.requestDivorce()
                        } label: {
                            Text("Request Divorce")
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

struct PersonCardInfo: View {
    
    let name: String
    let address: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(name)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            HStack(spacing: 0) {
                Text("Address: \(address)")
                    .font(.system(size: 13))
                    .fontWeight(.regular)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .truncationMode(.middle)
            
                Button {
                    UIPasteboard.general.string = address
                } label: {
                    Image("ic_copy")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                }
                .padding(.leading, 10)
            }
            .padding(.top, 6)
            .padding(.trailing, 24)
        }
    }
}

struct MarriageScreen_Previews: PreviewProvider {
    static var previews: some View {
        MarriageScreen()
    }
}
