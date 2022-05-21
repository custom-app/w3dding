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
    
    var body: some View {
        GeometryReader { geometry in
            ZStack() {
                if showFirstScreen {
                    Image("Onboarding1")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width)
                        .ignoresSafeArea()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation {
                                    firstScreenState2 = true
                                }
                            }
                        }
                    if firstScreenState2 {
                        Image("Onboarding1_2")
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width)
                            .ignoresSafeArea()
                            .onAppear {
                                DispatchQueue.main.async {
                                    withAnimation() {
                                        showFirstScreenText = true
                                    }
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
                                        colors: [Color(hex: "#0DFD61"), Color(hex: "#35e598")],
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
                            Spacer()
                        }
                        .padding(.top, 40)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.spring(response: 1.5, dampingFraction: 0.8, blendDuration: 0).speed(0.75))
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
