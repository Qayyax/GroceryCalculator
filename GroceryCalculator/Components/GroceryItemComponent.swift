//
//  GroceryItemComponent.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-09.
//

import SwiftUI

struct GroceryItemComponent: View {
    @State private var itemCount: Int = 1
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
            .padding(.bottom, 4)
            HStack {
                CustomStepper(value: $itemCount, range: 1...1000)
                Spacer()
            }
        
        }
    }
}

#Preview {
    GroceryItemComponent()
}
