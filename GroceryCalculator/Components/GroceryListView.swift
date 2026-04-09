//
//  GroceryListView.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-07.
//

import SwiftUI
let specific = Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 7, hour: 10, minute: 30)) ?? Date()

struct GroceryListView: View {
    var title: String
    var date: Date
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2.bold())
            Text(date, format: .dateTime.day().month().year())
        }
    }
}

#Preview {
    GroceryListView(title: "CVS Grocery List", date: specific)
}
