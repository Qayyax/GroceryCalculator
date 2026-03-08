//
//  ListsView.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-07.
//

import SwiftUI


struct ListsView: View {
    
    private var ListDemo: [GroceryList] = [
        GroceryList(title: "CVS Grocery list", date: specific),
        GroceryList(title: "Peter's Groceries", date: specific),
        GroceryList(title: "Farmer's market run", date: specific),
    ]
    
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
                    List(ListDemo) { list in
                        GroceryListView(title: list.title, date: list.date)
                    }
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    ListsView()
}
