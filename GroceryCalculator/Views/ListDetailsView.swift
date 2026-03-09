//
//  ListDetailsView.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-09.
//

import SwiftUI

struct ListDetailsView: View {
    let title: String
    var body: some View {
        ZStack {
            Color.primaryBg
                .ignoresSafeArea()
            VStack {
                
            }
            
        }
        .navigationTitle(title)
    }
}

#Preview {
    ListDetailsView(title: "Test")
}
