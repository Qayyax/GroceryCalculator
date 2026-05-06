//
//  NotesPerListView.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-23.
//

import SwiftUI

struct NotesPerListView: View {
    let list: GroceryList

    @Environment(\.dismiss) private var dismiss
    @Environment(ListsStore.self) private var listStore

    @State private var attributedText: NSAttributedString = NSAttributedString(string: "")

    var body: some View {
        NavigationStack {
            RichTextEditor(attributedText: $attributedText, autoFocus: true)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(Color.primaryBg)
                .navigationTitle(list.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { dismiss() }
                            .fontWeight(.semibold)
                    }
                }
        }
        .onAppear {
            attributedText = currentNotes
        }
        .onDisappear {
            saveNotes()
        }
    }

    private var currentNotes: NSAttributedString {
        guard
            let data = list.notesData,
            let decoded = NSAttributedString.decoded(from: data)
        else {
            return NSAttributedString(string: "")
        }
        return decoded
    }

    private func saveNotes() {
        let isEmpty = attributedText.string
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
        listStore.updateNotes(for: list, data: isEmpty ? nil : attributedText.encoded())
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: GroceryList.self, GroceryItem.self, configurations: config)
    let list = GroceryList(title: "Weekly Shop", budget: 150.00)
    container.mainContext.insert(list)

    return NotesPerListView(list: list)
        .modelContainer(container)
        .environment(ListsStore(modelContext: container.mainContext))
}
