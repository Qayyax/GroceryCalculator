//
//  ListsView.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-07.
//

import SwiftUI

struct ListsView: View {
    var body: some View {
        ZStack {
            Color.primaryBg
                .ignoresSafeArea()
            VStack(alignment: .leading) {
                NavigationStack {
                   Text("List")
                        .font(Font.largeTitle.bold())
                    
                    Text("Search component goes here")
                    
                    // list of items goes here
                }
            }
        }
    }
}

#Preview {
    ListsView()
}
