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
            ZStack(alignment: .top) {
                Image("DefaultBackground")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(.gray.opacity(0.5))
                        .cornerRadius(10)
                        .frame(width: 60, height: 6)
                        .padding(.top, 8)
                    
                    Text("Select Template")
                        .font(Font.title.bold())
                        .foregroundColor(Colors.darkPurple)
                        .padding(.top, 14)
                        .padding(.bottom, 14)
                    
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(globalViewModel.templates, id: \.id) { template in
                                TemplateView(showPicker: $showPicker, template: template)
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 16)
                            }
                        }
                        .padding(.bottom, 50)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height-50)
                }
            }
        }
        .environmentObject(globalViewModel)
    }
}

struct TemplateView: View {
    
    @EnvironmentObject
    var globalViewModel: GlobalViewModel
    
    @Binding
    var showPicker: Bool
    
    @State
    var template: CertificateTemplate
    
    var body: some View {
        Button {
            withAnimation {
                globalViewModel.selectedTemplate = template
            }
            showPicker = false
        } label: {
            ZStack(alignment: .topLeading) {
                Image("preview_cert\(template.id)")
                    .resizable()
                    .scaledToFit()
                
                Text(template.name)
                    .font(.system(size: 16))
                    .foregroundColor(Colors.darkPurple)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(6, corners: [.topLeft, .bottomRight])
            }
            .cornerRadius(6)
        }
    }
}
