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
                    TextField("$00", text: $name)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
                        .background{
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.white)
                        }
                    
                    HStack(alignment: .center){
                        Button{
                            
                        }label: {
                            Text("Add Item")
                            // background color should be Color.gray when disabled,
                            // should be Color.budgetBlue when enabled
                            // foreground text should be Color.itemAmountGray when disabled
                            // should be Color.white when enabled
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background{
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.blue)
                                    
                                }
                        }
                    }
                    .padding(.top, 40)
                    .frame(maxWidth: .infinity)
                    
                    Spacer()
                }
                
                .padding()
            }
            .navigationTitle("Add item")
        }
    }
}

#Preview {
    AddItemComponent()
}
