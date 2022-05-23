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
    
    @State
    var shareLoading = false
    
    var body: some View {
        VStack(spacing: 0) {
            let marriage = globalViewModel.marriage
            if globalViewModel.isErrorLoadingMeta {
                Spacer()
                
                Text("Error occured while loading marriage info")
                    .font(Font.headline.weight(.bold))
                    .foregroundColor(Colors.darkPurple)
                    .padding(.horizontal, 20)
                    .multilineTextAlignment(.center)
                
                Button {
                    globalViewModel.requestMarriageMeta()
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
            } else if let meta = globalViewModel.marriageMeta, !marriage.isEmpty() {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        PersonCardInfo(name: meta.properties.firstPersonName,
                                       address: marriage.authorAddress)
                        
                        Text("in wedlock with")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.vertical, 18)
                        
                        PersonCardInfo(name: meta.properties.secondPersonName,
                                       address: marriage.receiverAddress)
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
                
                if marriage.divorceState == .notRequested, let url = URL(string: meta.httpImageLink())  {
                    if shareLoading {
                        WeddingProgress()
                            .padding(.top, 32)
                        Text("Loading certificate")
                            .font(Font.headline.bold())
                            .foregroundColor(Colors.darkPurple)
                            .padding(.top, 24)
                    } else {
                        Button {
                            withAnimation {
                                shareLoading = true
                            }
                            DispatchQueue.global(qos: .userInitiated).async {
                                URLSession.shared.dataTask(with: URL(string: meta.httpImageLink())!) { data, response, error in
                                    if error != nil {
                                        DispatchQueue.main.async {
                                            withAnimation {
                                                shareLoading = false
                                            }
                                        }
                                        return
                                    }
                                    guard let data = data else {
                                        return
                                    }
                                    print("loaded cert image")
                                    DispatchQueue.main.async {
                                        withAnimation {
                                            shareLoading = false
                                        }
                                    }
                                    if let certImage = UIImage(data: data) {
                                        DispatchQueue.main.async {
                                            let activityController = UIActivityViewController(activityItems: [certImage], applicationActivities: nil)
                                            UIApplication.shared.windows.first?.rootViewController!
                                                .present(activityController, animated: true, completion: nil)
                                        }
                                    }
                                }
                                .resume()
                            }
                        } label: {
                            Text("Share")
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
                        .padding(.top, 32)
                    }
                }
                
                VStack(spacing: 0) {
                    Spacer()
                    if marriage.divorceState != .notRequested {
                        if let address = globalViewModel.walletAccount {
                            let isAuthor = address == marriage.authorAddress.lowercased()
                            
                            if (isAuthor && marriage.divorceState == .requestedByReceiver) ||
                                (!isAuthor && marriage.divorceState == .requestedByAuthor) {
                                Image("ic_warning")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 48)
                                    .padding(.top, 30)
                                
                                Text("The partner initiated the divorce")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Colors.darkPurple)
                                    .padding(.top, 24)
                                
                                Button {
                                    globalViewModel.confirmDivorce()
                                } label: {
                                    Text("Confirm")
                                        .font(.system(size: 17))
                                        .fontWeight(.bold)
                                        .foregroundColor(Colors.purple)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 15)
                                        .background(Color.white.opacity(0.5))
                                        .cornerRadius(32)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 32)
                                                .stroke(Colors.purple, lineWidth: 2)
                                        )
                                }
                                .padding(.top, 24)
                            } else if (isAuthor && marriage.divorceState == .requestedByAuthor) ||
                                        (!isAuthor && marriage.divorceState == .requestedByReceiver) {
                                let curTime = Int64((Date().timeIntervalSince1970).rounded())
                                let uniDivorceTime = marriage.divorceRequestTimestamp + marriage.divorceTimeout
                                if curTime > marriage.divorceRequestTimestamp + marriage.divorceTimeout {
                                    Image("ic_warning")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 42)
                                        .padding(.top, 20)
                                    
                                    Text("The partner did not confirm the divorce. You can divorce unilaterally")
                                        .font(.system(size: 19))
                                        .fontWeight(.bold)
                                        .foregroundColor(Colors.darkPurple)
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 20)
                                    
                                    Button {
                                        globalViewModel.confirmDivorce()
                                    } label: {
                                        Text("Divorce")
                                            .font(.system(size: 17))
                                            .fontWeight(.bold)
                                            .foregroundColor(Colors.purple)
                                            .padding(.horizontal, 24)
                                            .padding(.vertical, 15)
                                            .background(Color.white.opacity(0.5))
                                            .cornerRadius(32)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 32)
                                                    .stroke(Colors.purple, lineWidth: 2)
                                            )
                                    }
                                    .padding(.top, 20)
                                } else {
                                    Image("ic_warning")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 48)
                                        .padding(.top, 40)
                                    
                                    Text("Divorce in progress")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(Colors.darkPurple)
                                        .padding(.top, 24)
                                    
                                    let divorceDate = Date(timestamp: Int64(uniDivorceTime))
                                    
                                    Text("You will be able to divorce unilaterally after " +
                                         "\(divorceDate.formattedDateString("HH:mm dd.MM.yyyy"))")
                                        .font(.body)
                                        .fontWeight(.regular)
                                        .foregroundColor(Colors.darkPurple)
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 20)
                                }
                            }
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 28)
            } else {
                Spacer()
                
                //TODO: move loader to center
                VStack(spacing: 0) {
                    WeddingProgress()
                    Text("Loading data")
                        .font(Font.headline.bold())
                        .foregroundColor(Colors.darkPurple)
                        .padding(.top, 24)
                }
                
                Spacer()
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
