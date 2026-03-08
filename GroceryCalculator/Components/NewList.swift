//
//  NewList.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-08.
//

import SwiftUI

struct NewList: View {
    @State private var title: String = ""
    @State private var budget: Double? = 0.0
    @FocusState private var focusedField: Field?
    
    private enum Field: Hashable { case title, budget }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Create New List") {
                    TextField("Enter Title", text: $title)
                        .focused($focusedField, equals: .title)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled(true)
                }
                
                Section("Budget") {
                    TextField("$300.00", value: $budget, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .budget)
                }
                
                if let budget {
                    Section("Summary") {
                        LabeledContent("Title", value: title.isEmpty ? "—" : title)
                        LabeledContent("Budget", value: budget.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD")))
                    }
                }
            }
            .navigationTitle("New List")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focusedField = nil }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        // TODO: Handle save action
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    NewList()
}
