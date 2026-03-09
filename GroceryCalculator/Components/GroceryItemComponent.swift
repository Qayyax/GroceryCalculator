//
//  GroceryItemComponent.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-09.
//

import SwiftUI

struct GroceryItemComponent: View {
    var body: some View {
        VStack(spacing: 4) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("Item name")
                        .font(.title2.weight(.semibold))
                    Text("Item amount")
                        .foregroundStyle(.itemAmountGray)
                }
                Spacer()
                Text("Total Amount")
                    .font(.title2.bold())
            }
            // Picker goes here
        }
    }
}

#Preview {
    GroceryItemComponent()
}
