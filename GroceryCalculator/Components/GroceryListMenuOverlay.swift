//
//  GroceryListMenuOverlay.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-04-09.
//

import SwiftUI

struct GroceryListMenuOverlay: View {
    let listID: GroceryList.ID

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            menuRow(
                icon: "slider.horizontal.3",
                label: "Set Budget",
                color: .budgetBlue
            ) {
                // TODO: set budget functionality
                dismiss()
            }

            Divider().padding(.leading, 56)

            menuRow(
                icon: "clock.arrow.circlepath",
                label: "Save to History",
                color: .budgetBlue
            ) {
                // TODO: save to history functionality
                dismiss()
            }

            Divider()
                .padding(.vertical, 8)

            menuRow(
                icon: "trash",
                label: "Clear List",
                color: .red
            ) {
                // TODO: clear list functionality
                dismiss()
            }
        }
        .padding(.horizontal)
        .padding(.top, 24)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.primaryBg)
        .presentationDetents([.height(240)])
.presentationCornerRadius(20)
    }

    private func menuRow(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(color)
                    .frame(width: 28)

                Text(label)
                    .font(.body)
                    .foregroundStyle(color == .red ? .red : .primary)

                Spacer()
            }
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let store = ListsStore()
    let sampleList = GroceryList(id: UUID(), title: "Weekly Shop", budget: 150.00 as Decimal)
    store.lists.append(sampleList)

    return Color.gray
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            GroceryListMenuOverlay(listID: sampleList.id)
        }
        .environment(store)
}
