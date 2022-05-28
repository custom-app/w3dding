//
//  OnboardingScreen.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 21.05.2022.
//

import SwiftUI

struct OnboardingScreen: View {
    
    @EnvironmentObject
    var onboardingViewModel: OnboardingViewModel
    
    @EnvironmentObject
    var globalViewModel: GlobalViewModel
    
    @State
    var showFirstScreen = true
    
    @State
    var showFirstScreenWithLabel = false
    
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
    
    @State
    var showThirdScreenStepText = false
    
    @State
    var showThirdScreenTitle = false
    
    @State
    var showThirdScreenMainText = false
    
    @State
    var showThirdScreenCupid = false
    
    @State
    var showThirdScreenBtn = false
    
    @State
    var showFourthScreen = false
    
    @State
    var showFourthScreenStepText = false
    
    @State
    var showFourthScreenTitle = false
    
    @State
    var showFourthScreenMainText = false
    
    @State
    var showFourthScreenCupid = false
    
    @State
    var showFourthScreenBtn = false
    
    @State
    var showFifthScreen = false
    
    @State
    var showFifthScreenSuccessText = false
    
    @State
    var showFifthScreenMainText = false
    
    @State
    var showFifthScreenAdditionalText = false
    
    @State
    var showFifthScreenRays = false
    
    @State
    var showFifthScreenCupids = false
    
    @State
    var showFifthScreenBtn = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if showFirstScreen {
                    if !showSecondScreen {
                        Image("Onboarding1")
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height+100)
                            .ignoresSafeArea()
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    withAnimation {
                                        showFirstScreenWithLabel = true
                                    }
                                }
                            }
                    }
                    if showFirstScreenWithLabel {
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
                                .animation(.easeIn(duration: 1.00).delay(0.65), value: showSecondScreen)
                            
                            if showSecondScreen {
                                ZStack(alignment: .top) {
                                    Image("Onboarding2")
                                        .resizable()
                                        .scaledToFit()
                                    
                                    VStack(spacing: 0) {
                                        Text("Here you can Mint a holy NFT\nAgreement of Love & Loyalty\nwith your partner on Polygon")
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
                                            .shadow(color: Color(hex: "#B20CFC"), radius: 0, x: 1, y: 0)
                                            .shadow(color: Color(hex: "#7F39FB"), radius: 0, x: 0, y: 1)
                                        
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
                                                .shadow(color: Color(hex: "#7F39FB"), radius: 0, x: 0, y: 2)
                                                .padding(.horizontal, 26)
                                                .padding(.top, 6)
                                                .padding(.bottom, 8)
                                                .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#F600FB"), Color(hex: "#BD00FF")]),
                                                                           startPoint: .leading,
                                                                           endPoint: .trailing))
                                                .cornerRadius(2)
                                        }
                                        .padding(.top, geometry.size.height*0.018)
                                    }
                                    .padding(.horizontal, 50)
                                    .padding(.top, geometry.size.height*0.056)
                                }
                                .frame(height: showSecondScreen ? 400 : 0)
                                .transition(.move(edge: .bottom))
                                .animation(.easeIn(duration: 1.65))
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
                                .shadow(color: Color(hex: "#7F39FB"), radius: 0, x: 0, y: 2)
                                .opacity(showSecondScreen ? 0 : 1)
                            Spacer()
                        }
                        .padding(.top, showSecondScreen ? -150 : 40)
                        .opacity(showSecondScreen ? 0 : 1)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.spring(response: 1.5, dampingFraction: 0.8, blendDuration: 0).speed(1.5))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
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
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        withAnimation {
                                            showThirdScreenStepText = true
                                        }
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                                        withAnimation {
                                            showThirdScreenTitle = true
                                        }
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                                        withAnimation {
                                            showThirdScreenMainText = true
                                        }
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                                        withAnimation {
                                            showThirdScreenCupid = true
                                        }
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                        withAnimation {
                                            showThirdScreenBtn = true
                                        }
                                    }
                                }
                            
                            if showThirdScreenStepText {
                                Text("STEP 1")
                                    .font(Font.custom("marediv", size: 40))
                                    .multilineTextAlignment(.center)
                                    .overlay(
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
                                    .shadow(color: Color(hex: "#7F39FB"), radius: 0, x: 0, y: 1)
                                    .padding(.top, 40)
                                    .transition(.move(edge: .leading).combined(with: .opacity))
                                    .animation(.spring(response: 1.5, dampingFraction: 0.8, blendDuration: 0).speed(1.5))
                                    .onAppear {
                                        
                                    }
                            }
                        }
                        
                        ZStack(alignment: .bottom) {
                            Image("Onboarding3_bottom")
                                .resizable()
                                .frame(width: geometry.size.width, height: geometry.size.height * 0.42)
                            
                            if showThirdScreenCupid {
                                HStack(spacing: 0) {
                                    Image("Onboarding3_cupid")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: geometry.size.width*0.37)
                                    Spacer()
                                }
                                .transition(.move(edge: .leading).combined(with: .opacity))
                                .animation(.easeIn(duration: 0.5))
                            }
                            
                            VStack(spacing: 0) {
                                Text("To mint an NFT Agreement of Love & Loyalty:")
                                    .font(Font.custom("marediv", size: 19))
                                    .foregroundColor(Color(hex: "#7E3906"))
                                    .multilineTextAlignment(.leading)
                                    .padding(.horizontal, geometry.size.width*0.151)
                                    .opacity(showThirdScreenTitle ? 1 : 0)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("1. Connect your crypto wallet")
                                        .font(Font.custom("marediv", size: 14))
                                        .foregroundColor(Color(hex: "#7E3906"))
                                        .multilineTextAlignment(.leading)
                                    
                                    Text("2. Get Matic from our Faucet")
                                        .font(Font.custom("marediv", size: 14))
                                        .foregroundColor(Color(hex: "#7E3906"))
                                        .multilineTextAlignment(.leading)
                                    
                                    Text("3. Send a proposal to the partner")
                                        .font(Font.custom("marediv", size: 14))
                                        .foregroundColor(Color(hex: "#7E3906"))
                                        .multilineTextAlignment(.leading)
                                    
                                    Text("4. Ask your partner to accept it")
                                        .font(Font.custom("marediv", size: 14))
                                        .foregroundColor(Color(hex: "#7E3906"))
                                        .multilineTextAlignment(.leading)
                                    
                                }
                                .padding(.horizontal, geometry.size.width*0.146)
                                .padding(.leading, geometry.size.width*0.068)
                                .padding(.top, geometry.size.height*0.020)
                                .padding(.bottom, geometry.size.height*0.020)
                                .opacity(showThirdScreenMainText ? 1 : 0)
                                
                                HStack(spacing: 0) {
                                     Spacer()
                                     Button {
                                         withAnimation {
                                             showFourthScreen = true
                                             showThirdScreen = false
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
                                             .shadow(color: Color(hex: "#7F39FB"), radius: 0, x: 0, y: 2)
                                             .padding(.horizontal, 26)
                                             .padding(.top, 6)
                                             .padding(.bottom, 8)
                                             .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#F600FB"), Color(hex: "#BD00FF")]),
                                                                        startPoint: .leading,
                                                                        endPoint: .trailing))
                                             .cornerRadius(2)
                                     }
                                     .opacity(showThirdScreenBtn ? 1 : 0)
                                 }
                                 .padding(.trailing, geometry.size.width*0.175)
                                 .padding(.bottom, geometry.size.height*0.069)
                            }
                        }
                        .padding(.top, -2)
                    }
                } else if showFourthScreen {
                    VStack(spacing: 0) {
                        ZStack(alignment: .top) {
                            Image("Onboarding4_top")
                                .resizable()
                                .frame(width: geometry.size.width)
                                .edgesIgnoringSafeArea(.top)
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        withAnimation {
                                            showFourthScreenStepText = true
                                        }
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                                        withAnimation {
                                            showFourthScreenTitle = true
                                        }
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                                        withAnimation {
                                            showFourthScreenMainText = true
                                        }
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                                        withAnimation {
                                            showFourthScreenCupid = true
                                        }
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                        withAnimation {
                                            showFourthScreenBtn = true
                                        }
                                    }
                                }
                            
                            if showFourthScreenStepText {
                                Text("STEP 2")
                                    .font(Font.custom("marediv", size: 40))
                                    .multilineTextAlignment(.center)
                                    .overlay (
                                        LinearGradient(
                                            colors: [Color(hex: "#00FC83"), Color(hex: "#FAFF14")],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                        .mask(
                                            Text("STEP 2")
                                                .font(Font.custom("marediv", size: 40))
                                                .multilineTextAlignment(.center)
                                        )
                                    )
                                    .shadow(color: Color(hex: "#B20CFC"), radius: 0, x: 1, y: 0)
                                    .shadow(color: Color(hex: "#7F39FB"), radius: 0, x: 0, y: 1)
                                    .padding(.top, 40)
                                    .transition(.move(edge: .leading).combined(with: .opacity))
                                    .animation(.spring(response: 1.5, dampingFraction: 0.8, blendDuration: 0).speed(1.5))
                            }
                        }
                        
                        ZStack(alignment: .bottom) {
                            Image("Onboarding3_bottom")
                                .resizable()
                                .frame(width: geometry.size.width, height: geometry.size.height * 0.42)
                                
                            if showFourthScreenCupid {
                                HStack(spacing: 0) {
                                    Spacer()
                                    Image("Onboarding4_cupid")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: geometry.size.height*0.21)
                                }
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                                .animation(.easeIn(duration: 0.5))
                            }
                            
                            VStack(alignment: .leading, spacing: 0) {
                                Text("To accept the Proposal")
                                    .font(Font.custom("marediv", size: 19))
                                    .foregroundColor(Color(hex: "#7E3906"))
                                    .multilineTextAlignment(.leading)
                                    .padding(.horizontal, geometry.size.width*0.158)
                                    .opacity(showFourthScreenTitle ? 1 : 0)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("1. Connect your crypto wallet")
                                        .font(Font.custom("marediv", size: 15))
                                        .foregroundColor(Color(hex: "#7E3906"))
                                        .multilineTextAlignment(.leading)
                                    
                                    Text("2. Get Matic from our Faucet")
                                        .font(Font.custom("marediv", size: 15))
                                        .foregroundColor(Color(hex: "#7E3906"))
                                        .multilineTextAlignment(.leading)
                                    
                                    Text("3. Accept the Proposal in the App")
                                        .font(Font.custom("marediv", size: 15))
                                        .foregroundColor(Color(hex: "#7E3906"))
                                        .multilineTextAlignment(.leading)
                                }
                                .padding(.horizontal, geometry.size.width*0.158)
                                .padding(.top, 16)
                                .padding(.bottom, 30)
                                .opacity(showFourthScreenMainText ? 1 : 0)
                                
                                HStack(spacing: 0) {
                                    Button {
                                        withAnimation {
                                            showFifthScreen = true
                                            showFourthScreen = false
                                        }
                                    } label: {
                                        HStack(spacing: 0) {
                                            Text("AND SO\nWHAT?")
                                                .font(Font.custom("marediv", size: 19))
                                                .multilineTextAlignment(.center)
                                                .overlay (
                                                    LinearGradient(
                                                        colors: [Color(hex: "#B20CFC"), Color(hex: "#6E01F0")],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                    .mask(
                                                        Text("AND SO\nWHAT?")
                                                            .font(Font.custom("marediv", size: 19))
                                                            .multilineTextAlignment(.center)
                                                    )
                                                )
                                                .shadow(color: Color(hex: "#B20CFC"), radius: 0, x: 1, y: 0)
                                                .shadow(color: Color(hex: "#7F39FB"), radius: 0, x: 0, y: 1)
                                            
                                            Image("ic_btn_arrow")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 32)
                                                .padding(.leading, 8)
                                                .padding(.top, 2)
                                        }
                                        .padding(.leading, 26)
                                        .padding(.trailing, 17)
                                        .padding(.vertical, 6)
                                        .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#0DFD61"), Color(hex: "#39EFFB")]),
                                                                   startPoint: .top,
                                                                   endPoint: .bottom))
                                        .cornerRadius(24)
                                    }
                                    .opacity(showFourthScreenBtn ? 1 : 0)
                                    Spacer()
                                }
                                .padding(.leading, geometry.size.width*0.167)
                                .padding(.bottom, geometry.size.height*0.088)
                            }
                        }
                        .padding(.top, -2)
                    }
                } else if showFifthScreen {
                    Image("Onboarding5_background")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width)
                        .ignoresSafeArea()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation {
                                    showFifthScreenSuccessText = true
                                }
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                                withAnimation {
                                    showFifthScreenMainText = true
                                }
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                withAnimation {
                                    showFifthScreenAdditionalText = true
                                }
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.25) {
                                withAnimation {
                                    showFifthScreenCupids = true
                                }
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                                withAnimation {
                                    showFifthScreenRays = true
                                }
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 4.25) {
                                withAnimation {
                                    showFifthScreenBtn = true
                                }
                            }
                        }
                    
                    Image("rays_modified")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width)
                        .ignoresSafeArea()
                        .opacity(showFifthScreenRays ? 1 : 0)
                    
                    VStack(spacing: 0) {

                        if showFifthScreenSuccessText {
                            Text("SUCCESS")
                                .font(Font.custom("marediv", size: 40))
                                .multilineTextAlignment(.center)
                                .overlay (
                                    LinearGradient(
                                        colors: [Color(hex: "#FF0000"), Color(hex: "#FAFF14")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    .mask(
                                        Text("SUCCESS")
                                            .font(Font.custom("marediv", size: 40))
                                            .multilineTextAlignment(.center)
                                    )
                                )
                                .shadow(color: Color(hex: "#B20CFC"), radius: 0, x: 1, y: 0)
                                .shadow(color: Color(hex: "#7F39FB"), radius: 0, x: 0, y: 1)
                                .padding(.bottom, 40)
                                .transition(.move(edge: .top).combined(with: .opacity))
                                .animation(.spring(response: 1.5, dampingFraction: 0.8, blendDuration: 0).speed(1.5))
                        }

                        Text("Your union is concluded and\nregistered in the Polygon\nblockchain!")
                            .font(.system(size: 24))
                            .foregroundColor(Color.white)
                            .multilineTextAlignment(.center)
                            .shadow(color: Color(hex: "#B20CFC"), radius: 0, x: 1, y: 0)
                            .shadow(color: Color(hex: "#7F39FB"), radius: 0, x: 0, y: 1)
                            .padding(.bottom, 40)
                            .padding(.horizontal, 20)
                            .opacity(showFifthScreenMainText ? 1 : 0)

                        Text("It will be stored as an NFT\nforever!")
                            .font(.system(size: 24))
                            .foregroundColor(Color.white)
                            .multilineTextAlignment(.center)
                            .shadow(color: Color(hex: "#B20CFC"), radius: 0, x: 1, y: 0)
                            .shadow(color: Color(hex: "#7F39FB"), radius: 0, x: 0, y: 1)
                            .padding(.bottom, 22)
                            .padding(.horizontal, 20)
                            .opacity(showFifthScreenMainText ? 1 : 0)

                        Text("*Well, or until you decide to divorce :)")
                            .font(Font.custom("marediv", size: 14))
                            .foregroundColor(Color.white)
                            .multilineTextAlignment(.center)
                            .shadow(color: Color(hex: "#B20CFC"), radius: 0, x: 1, y: 0)
                            .shadow(color: Color(hex: "#7F39FB"), radius: 0, x: 0, y: 1)
                            .padding(.bottom, 14)
                            .padding(.horizontal, 20)
                            .opacity(showFifthScreenAdditionalText ? 1 : 0)

                        if showFifthScreenCupids {
                            Image("Onboarding5_cupids")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.height*0.23)
                                .padding(.bottom, geometry.size.height*0.12)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                                .animation(.easeIn(duration: 0.25))
                        } else {
                            Image("Onboarding5_cupids")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.height*0.23)
                                .padding(.bottom, geometry.size.height*0.12)
                                .opacity(0)
                        }

                        Button {
                            UserDefaultsWorker.shared.setOnBoardingShown(shown: true)
                            onboardingViewModel.stopMusic()
                            withAnimation {
                                globalViewModel.showingOnboarding = false
                            }
                        } label: {
                            Text("LET`S MINT")
                                .font(.system(size: 26))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 35)
                                .padding(.vertical, 17)
                                .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#B20CFC"), Color(hex: "#6E01F0")]),
                                                           startPoint: .leading,
                                                           endPoint: .trailing))
                                .cornerRadius(32)
                        }
                        .padding(.bottom, geometry.size.height*0.025)
                        .shadow(color: Color.white.opacity(0.5), radius: 60, x: 0, y: 0 )
                        .opacity(showFifthScreenBtn ? 1 : 0)
                    }
                } else {
                    EmptyView()
                }
            }
            .background(Color.black.ignoresSafeArea(.all))
        }
    }
}

struct OnboardingScreen_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingScreen()
    }
}
