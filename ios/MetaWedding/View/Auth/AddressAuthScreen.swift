//
//  AddressAuthScreen.swift
//  MetaWedding
//
//  Created by Lev Baklanov on 05.11.2022.
//

import SwiftUI

struct AddressAuthScreen: View {
    
    @EnvironmentObject
    var globalVm: GlobalViewModel
    
    @State
    var address = ""
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("DefaultBackground")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Colors.darkPurple.opacity(0.3))
                        .frame(width: 64, height: 6)
                        .cornerRadius(20)
                        .padding(.top, 12)
                    
                    Text("Connect by address")
                        .foregroundColor(Colors.darkPurple)
                        .font(.system(size: 34))
                        .fontWeight(.bold)
                        .padding(.top, 8)
                    
                    Text("Enter your address")
                        .foregroundColor(Colors.darkGrey)
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                        .padding(.top, 28)
                        .padding(.horizontal, 10)
                    
                    TextField("", text: $address)
                        .font(.system(size: 17, weight: .bold))
                        .placeholder(when: address.isEmpty) {
                            HStack {
                                Text("0x.......")
                                    .font(.system(size: 17))
                                    .foregroundColor(Colors.darkPurple.opacity(0.65))
                                Spacer()
                            }
                        }
                        .foregroundColor(Colors.darkPurple)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 13)
                        .background(Color.white.opacity(0.5))
                        .cornerRadius(32)
                        .padding(.horizontal, 16)
                        .padding(.top, 32)
                    
                    Button {
                        hideKeyboard()
                        if Tools.isAddressValid(address) {
                            globalVm.authByAddress(address)
                            globalVm.showAddressAuthSheet = false
                        } else {
                            globalVm.alert = IdentifiableAlert.build(
                                id: "invalid_address",
                                title: "Invalid address",
                                message: "Please enter valid address starting with 0x"
                            )
                        }
                    } label: {
                        Text("Connect")
                            .font(.system(size: 17))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 15)
                            .background(Colors.purple)
                            .cornerRadius(32)
                    }
                    .padding(.top, 34)
                    
                    Text("*We recommend to authorize through wallet connection for better experience")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Colors.darkPurple.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                    Spacer()
                }
                .frame(width: geometry.size.width)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .alert(item: $globalVm.alert) { alert in
            alert.alert()
        }
    }
}
