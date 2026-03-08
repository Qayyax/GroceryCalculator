//
//  ListsView.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-07.
//

import SwiftUI


struct ListsView: View {
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.primaryBg
                    .ignoresSafeArea()
                VStack(alignment: .leading) {
                    Text("Search component goes here")
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                    
                    // list of items goes here
                    List(ListDemo) { list in
                        GroceryListView(title: list.title, date: list.date)
                    }
                    Spacer()
                }
            }
            .navigationTitle("Lists")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                       print("added")
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(.accent)
                    }
                }
            }
        }
    }
}

#Preview {
    ListsView()
}
