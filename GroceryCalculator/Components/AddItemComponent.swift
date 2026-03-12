//
//  AddItemComponent.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-12.
//

import SwiftUI

struct AddItemComponent: View {
    @State privar
    var body: some View {
        NavigationStack{
            Form {
               Text("Product Name")
               Text("Price")
            }
            .navigationTitle("Add item")
        }
    }
}

#Preview {
    AddItemComponent()
}
