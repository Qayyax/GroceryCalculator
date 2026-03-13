//
//  NewList.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-08.
//

import SwiftUI

struct NewList: View {
    var onSave: (String, Double) -> Void = { _, _ in }
    
    @State private var title: String = ""
    @State private var budget: String = ""
    @FocusState private var focusedField: Field?
    @Environment(\.dismiss) private var dismiss
    
    private enum Field: Hashable { case title, budget }
    
    private var budgetValue: Double? {
        Double(budget)
    }
    
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        budgetValue != nil &&
        (budgetValue ?? 0) > 0
    }
    
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
                    TextField("300.00", text: $budget)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .budget)
                }
                
                if let budgetValue {
                    Section("Summary") {
                        LabeledContent("Title", value: title.isEmpty ? "-" : title)
                        LabeledContent("Budget", value: budgetValue.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD")))
                    }
                }
            }
            .navigationTitle("New List")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        if let budgetValue {
                            onSave(title, budgetValue)
                            dismiss()
                        }
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
}

#Preview {
    NewList()
}
