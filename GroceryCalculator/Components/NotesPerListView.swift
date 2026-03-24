//
//  NotesPerListView.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-23.
//

import SwiftUI

struct NotesPerListView: View {
    let listID: GroceryList.ID

    @Environment(\.dismiss) private var dismiss
    @Environment(ListsStore.self) private var listStore

    @State private var attributedText: NSAttributedString = NSAttributedString(string: "")

    private var listTitle: String {
        listStore.lists.first(where: { $0.id == listID })?.title ?? "Notes"
    }

    var body: some View {
        NavigationStack {
            RichTextEditor(attributedText: $attributedText, autoFocus: true)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(Color.primaryBg)
                .navigationTitle(listTitle)
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
            let list = listStore.lists.first(where: { $0.id == listID }),
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
        listStore.updateNotes(for: listID, data: isEmpty ? nil : attributedText.encoded())
    }
}

#Preview {
    let store = ListsStore()
    let sampleList = GroceryList(id: UUID(), title: "Weekly Shop", budget: 150.00)
    store.lists.append(sampleList)

    return NotesPerListView(listID: sampleList.id)
        .environment(store)
}
