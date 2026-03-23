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

    private var currentNotes: NSAttributedString {
        guard
            let list = listStore.lists.first(where: { $0.id == listID }),
            let data = list.notesRTFData,
            let decoded = NSAttributedString.from(rtfData: data)
        else {
            return NSAttributedString(string: "")
        }
        return decoded
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.primaryBg
                    .ignoresSafeArea()

                RichTextEditor(attributedText: $attributedText)
                    .padding(.horizontal)
                    .padding(.top, 8)
            }
            .navigationTitle("Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        saveNotes()
                    }
                    .fontWeight(.semibold)
                }
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
            attributedText = currentNotes
        }
    }

    private func saveNotes() {
        let isEmpty = attributedText.string
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
        listStore.updateNotes(for: listID, rtfData: isEmpty ? nil : attributedText.rtfData())
        dismiss()
    }
}

#Preview {
    let store = ListsStore()
    let sampleList = GroceryList(id: UUID(), title: "Weekly Shop", budget: 150.00)
    store.lists.append(sampleList)

    return NotesPerListView(listID: sampleList.id)
        .environment(store)
}
