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
        Text("Marriage Screen")
    }
}

struct MarriageScreen_Previews: PreviewProvider {
    static var previews: some View {
        MarriageScreen()
    }
}
