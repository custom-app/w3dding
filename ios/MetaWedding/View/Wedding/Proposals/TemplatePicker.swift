//
//  TemplatePicker.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 10.05.2022.
//

import SwiftUI

struct TemplatePicker: View {
    
    @EnvironmentObject
    var globalViewModel: GlobalViewModel
    
    @Binding
    var showPicker: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("DefaultBackground")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(globalViewModel.templateIds, id: \.self) { id in
                            Button {
                                withAnimation {
                                    globalViewModel.selectedTemplateId = id
                                }
                                showPicker = false
                            } label: {
                                Image("preview_cert\(id)")
                                    .resizable()
                                    .scaledToFit()
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)
                        }
                        
                        ForEach(globalViewModel.templateIds, id: \.self) { id in
                            Button {
                                withAnimation {
                                    globalViewModel.selectedTemplateId = id
                                }
                                showPicker = false
                            } label: {
                                Image("preview_cert\(id)")
                                    .resizable()
                                    .scaledToFit()
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)
                        }
                    }
                    .padding(.bottom, 50)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}
