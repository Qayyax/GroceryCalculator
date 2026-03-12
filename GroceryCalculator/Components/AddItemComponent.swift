//
//  AddItemComponent.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-12.
//

import SwiftUI

struct AddItemComponent: View {
    @State private var name: String = ""
    @State private var price: Double? = nil
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack{
            ZStack{
                Color.primaryBg
                    .ignoresSafeArea()
                VStack(alignment: .leading, spacing: 10) {
                    Text("Product Name")
                    
                    TextField("Cereal, Bacon, Eggs...", text: $name)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
                        .background{
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.white)
                        }
                    
                    Text("Price")
                    Spacer()
                }
                
            }
            .navigationTitle("Add item")
        }
    }
}

#Preview {
    AddItemComponent()
}
