//
//  SetBudgetComponent.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-04-09.
//

import SwiftUI
import SwiftData

struct SetBudgetComponent: View {
    let list: GroceryList

    @Environment(\.dismiss) private var dismiss
    @Environment(ListsStore.self) private var listStore

    @State private var budgetText: String = ""

    private var budgetValue: Double? {
        let cleaned = budgetText
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
        guard !cleaned.isEmpty else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        guard let number = formatter.number(from: cleaned) else { return nil }
        return number.doubleValue
    }

    private var isFormValid: Bool {
        (budgetValue ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.primaryBg
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Budget")

                    TextField("0.00", text: $budgetText)
                        .keyboardType(.decimalPad)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.white)
                        }

                    Button {
                        saveBudget()
                    } label: {
                        Text("Update Budget")
                            .foregroundStyle(isFormValid ? Color.white : Color.itemAmountGray)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(isFormValid ? Color.budgetBlue : Color.buttonStrokeGray)
                            }
                    }
                    .disabled(!isFormValid)
                    .padding(.top, 40)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Set Budget")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
        .onAppear {
            budgetText = String(list.budget)
        }
    }

    private func saveBudget() {
        guard let value = budgetValue else { return }
        listStore.updateListMeta(list, budget: value)
        dismiss()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container: ModelContainer = try! ModelContainer(for: GroceryList.self, GroceryItem.self, configurations: config)
    let list = GroceryList(title: "Weekly Shop", budget: 150.00)
    container.mainContext.insert(list)

    SetBudgetComponent(list: list)
        .modelContainer(container)
        .environment(ListsStore(modelContext: container.mainContext))
}
