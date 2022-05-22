//
//  OnboardingScreen.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 21.05.2022.
//

import SwiftUI

struct OnboardingScreen: View {
    
    @EnvironmentObject
    var globalViewModel: GlobalViewModel
    
    @StateObject
    var onboardingViewModel = OnboardingViewModel()
    
    @State
    var showFirstScreen = true
    
    @State
    var firstScreenState2 = false
    
    @State
    var showFirstScreenText = false
    
    @State
    var showSecondScreen = false
    
    @State
    var showSecondScreenText = false
    
    @State
    var showSecondScreenButton = false
    
    @State
    var showThirdScreen = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack() {
                if showFirstScreen {
                    if !showSecondScreen {
                        Image("Onboarding1")
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height+100)
                            .ignoresSafeArea()
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation {
                                        firstScreenState2 = true
                                    }
                                }
                            }
                    }
                    if firstScreenState2 {
                        VStack(spacing: 0) {
                            Image("Onboarding1_2")
                                .resizable()
                                .scaledToFill()
                                .frame(width: geometry.size.width, height: (showSecondScreen ? geometry.size.height+100 - 400 : geometry.size.height+100))
                                .ignoresSafeArea()
                                .onAppear {
                                    DispatchQueue.main.async {
                                        withAnimation() {
                                            showFirstScreenText = true
                                        }
                                    }
                                }
                                .animation(.easeIn(duration: 1.40).delay(0.95), value: showSecondScreen)
                            
                            if showSecondScreen {
                                ZStack(alignment: .top) {
                                    Image("Onboarding2")
                                        .resizable()
                                        .scaledToFit()
                                    
                                    VStack(spacing: 0) {
                                        Text("Here you can Mint a holy NFT Agreement of Love & Loyalty with your partner on Polygon")
                                            .font(Font.custom("marediv", size: 19))
                                            .multilineTextAlignment(.center)
                                            .overlay (
                                                LinearGradient(
                                                    colors: [Color(hex: "#0DFD61"), Color(hex: "#39EFFB")],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                                .mask(
                                                    Text("Here you can Mint a holy NFT Agreement of Love & Loyalty with your partner on Polygon")
                                                        .font(Font.custom("marediv", size: 19))
                                                        .multilineTextAlignment(.center)
                                                )
                                            )
                                            .shadow(color: Color(hex: "#B20CFC"), radius: 0, x: 2, y: 0)
                                            .shadow(color: Color(hex: "#7F39FB"), radius: 1, x: 0, y: 2)
                                        
                                        Button {
                                            withAnimation {
                                                showThirdScreen = true
                                                showFirstScreen = false
                                            }
                                        } label: {
                                            Text("ENTER")
                                                .font(Font.custom("marediv", size: 19))
                                                .multilineTextAlignment(.center)
                                                .overlay (
                                                    LinearGradient(
                                                        colors: [Color(hex: "#0DFD61"), Color(hex: "#39EFFB")],
                                                        startPoint: .top,
                                                        endPoint: .bottom
                                                    )
                                                    .mask(
                                                        Text("ENTER")
                                                            .font(Font.custom("marediv", size: 19))
                                                            .multilineTextAlignment(.center)
                                                    )
                                                )
                                                .shadow(color: Color(hex: "#B20CFC"), radius: 0, x: 2, y: 0)
                                                .shadow(color: Color(hex: "#7F39FB"), radius: 1, x: 0, y: 2)
                                                .padding(.horizontal, 26)
                                                .padding(.top, 6)
                                                .padding(.bottom, 8)
                                                .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#F600FB"), Color(hex: "#BD00FF")]),
                                                                           startPoint: .leading,
                                                                           endPoint: .trailing))
                                                .cornerRadius(2)
                                        }
                                        .padding(.top, 12)
                                    }
                                    .padding(.horizontal, 50)
                                    .padding(.top, 38)
                                }
                                .frame(height: showSecondScreen ? 400 : 0)
                                .transition(.move(edge: .bottom))
                                .animation(.easeIn(duration: 2.35))
                            }
                        }
                    }
                    
                    if showFirstScreenText {
                        VStack(spacing: 0) {
                            Text("Hello,\nMetaverse stranger!")
                                .font(Font.custom("marediv", size: 28))
                                .multilineTextAlignment(.center)
                                .overlay (
                                    LinearGradient(
                                        colors: [Color(hex: "#0DFD61"), Color(hex: "#39FBAA")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    .mask(
                                        Text("Hello,\nMetaverse stranger!")
                                            .font(Font.custom("marediv", size: 28))
                                            .multilineTextAlignment(.center)
                                    )
                                )
                                .shadow(color: Color(hex: "#B20CFC"), radius: 0, x: 2, y: 0)
                                .shadow(color: Color(hex: "#7F39FB"), radius: 1, x: 0, y: 2)
                                .opacity(showSecondScreen ? 0 : 1)
                            Spacer()
                        }
                        .padding(.top, showSecondScreen ? -150 : 40)
                        .opacity(showSecondScreen ? 0 : 1)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.spring(response: 1.5, dampingFraction: 0.8, blendDuration: 0).speed(0.75))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    showSecondScreen = true
//                                    showFirstScreen = false
                                }
                            }
                        }
                    }
                } else if showThirdScreen {
                    VStack(spacing: 0) {
                        ZStack(alignment: .top) {
                            Image("Onboarding3_top")
                                .resizable()
                                .frame(width: geometry.size.width)
                                .edgesIgnoringSafeArea(.top)
                                .onAppear {
        //                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        //                                withAnimation {
        //                                    firstScreenState2 = true
        //                                }
        //                            }
                                }
                            
                            Text("STEP 1")
                                .font(Font.custom("marediv", size: 40))
                                .multilineTextAlignment(.center)
                                .overlay (
                                    LinearGradient(
                                        colors: [Color(hex: "#00FC83"), Color(hex: "#FAFF14")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    .mask(
                                        Text("STEP 1")
                                            .font(Font.custom("marediv", size: 40))
                                            .multilineTextAlignment(.center)
                                    )
                                )
                                .shadow(color: Color(hex: "#B20CFC"), radius: 0, x: 1, y: 0)
                                .shadow(color: Color(hex: "#7F39FB"), radius: 1, x: 0, y: 1)
                                .padding(.top, 40)
                        }
                        
                        ZStack(alignment: .bottom) {
                            Image("Onboarding3_bottom")
                                .resizable()
                                .frame(width: geometry.size.width, height: geometry.size.height * 0.42)
                                .onAppear {
        //                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        //                                withAnimation {
        //                                    firstScreenState2 = true
        //                                }
        //                            }
                                }
                            
                            VStack(spacing: 0) {
//                                Spacer()
                                HStack(spacing: 0) {
                                    Image("Onboarding3_cupid")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: geometry.size.width*0.37)
                                    Spacer()
                                }
                            }
                            
                            VStack(spacing: 0) {
                                Text("To mint an NFT Agreement of Love & Loyalty:")
                                    .font(Font.custom("marediv", size: 19))
                                    .foregroundColor(Color(hex: "#7E3906"))
                                    .multilineTextAlignment(.leading)
                                    .padding(.horizontal, 55)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("1. Connect your crypto wallet")
                                        .font(Font.custom("marediv", size: 15))
                                        .foregroundColor(Color(hex: "#7E3906"))
                                        .multilineTextAlignment(.leading)
                                    
                                    Text("2. Get Matic from our Faucet")
                                        .font(Font.custom("marediv", size: 15))
                                        .foregroundColor(Color(hex: "#7E3906"))
                                        .multilineTextAlignment(.leading)
                                    
                                    Text("3. Send a proposal to the partner")
                                        .font(Font.custom("marediv", size: 15))
                                        .foregroundColor(Color(hex: "#7E3906"))
                                        .multilineTextAlignment(.leading)
                                    
                                    Text("4. Ask your partner to accept it")
                                        .font(Font.custom("marediv", size: 15))
                                        .foregroundColor(Color(hex: "#7E3906"))
                                        .multilineTextAlignment(.leading)
                                    
                                }
                                .padding(.horizontal, 55)
                                .padding(.leading, 30)
                                .padding(.top, 16)
                                .padding(.bottom, 20)
                                
                                HStack(spacing: 0) {
                                    Spacer()
                                    Button {
                                        withAnimation {
                                            
                                        }
                                    } label: {
                                        Text("NEXT")
                                            .font(Font.custom("marediv", size: 19))
                                            .multilineTextAlignment(.center)
                                            .overlay (
                                                LinearGradient(
                                                    colors: [Color(hex: "#0DFD61"), Color(hex: "#39EFFB")],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                                .mask(
                                                    Text("NEXT")
                                                        .font(Font.custom("marediv", size: 19))
                                                        .multilineTextAlignment(.center)
                                                )
                                            )
                                            .shadow(color: Color(hex: "#B20CFC"), radius: 0, x: 2, y: 0)
                                            .shadow(color: Color(hex: "#7F39FB"), radius: 1, x: 0, y: 2)
                                            .padding(.horizontal, 26)
                                            .padding(.top, 6)
                                            .padding(.bottom, 8)
                                            .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#F600FB"), Color(hex: "#BD00FF")]),
                                                                       startPoint: .leading,
                                                                       endPoint: .trailing))
                                            .cornerRadius(2)
                                    }
                                }
                                .padding(.trailing, 64)
                                .padding(.bottom, 50)
                            }
                        }
                        .padding(.top, -2)
                    }
                } else {
                    EmptyView()
                }
            }
        }
    }
}

struct OnboardingScreen_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingScreen()
    }
}
