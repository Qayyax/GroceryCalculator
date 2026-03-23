//
//  RichTextEditor.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-23.
//

import SwiftUI
import UIKit

struct RichTextEditor: UIViewRepresentable {
    @Binding var attributedText: NSAttributedString

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.allowsEditingTextAttributes = true
        textView.backgroundColor = .clear
        textView.delegate = context.coordinator
        context.coordinator.textView = textView

        let bodyFont = UIFont.preferredFont(forTextStyle: .body)
        textView.font = bodyFont
        textView.typingAttributes = [
            .font: bodyFont,
            .foregroundColor: UIColor.label
        ]

        textView.inputAccessoryView = makeFormattingToolbar(coordinator: context.coordinator)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        guard !uiView.isFirstResponder else { return }
        uiView.attributedText = attributedText
    }

    private func makeFormattingToolbar(coordinator: Coordinator) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let boldButton = UIBarButtonItem(
            title: "B",
            style: .plain,
            target: coordinator,
            action: #selector(Coordinator.toggleBold)
        )
        boldButton.setTitleTextAttributes(
            [.font: UIFont.boldSystemFont(ofSize: 17)],
            for: .normal
        )

        let italicButton = UIBarButtonItem(
            title: "I",
            style: .plain,
            target: coordinator,
            action: #selector(Coordinator.toggleItalic)
        )
        italicButton.setTitleTextAttributes(
            [.font: UIFont.italicSystemFont(ofSize: 17)],
            for: .normal
        )

        let underlineButton = UIBarButtonItem(
            title: "U",
            style: .plain,
            target: coordinator,
            action: #selector(Coordinator.toggleUnderline)
        )
        underlineButton.setTitleTextAttributes(
            [
                .font: UIFont.systemFont(ofSize: 17),
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ],
            for: .normal
        )

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolbar.items = [boldButton, italicButton, underlineButton, flexSpace]
        return toolbar
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: RichTextEditor
        weak var textView: UITextView?

        init(_ parent: RichTextEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.attributedText = textView.attributedText
        }

        @objc func toggleBold() {
            guard let textView else { return }
            toggleTrait(.traitBold, in: textView)
        }

        @objc func toggleItalic() {
            guard let textView else { return }
            toggleTrait(.traitItalic, in: textView)
        }

        @objc func toggleUnderline() {
            guard let textView else { return }
            let range = textView.selectedRange

            if range.length > 0 {
                let mutable = NSMutableAttributedString(attributedString: textView.attributedText)
                // Check if ALL characters in the range have underline
                var allUnderlined = true
                mutable.enumerateAttribute(.underlineStyle, in: range) { value, _, _ in
                    if let style = value as? Int, style != 0 { return }
                    allUnderlined = false
                }
                if allUnderlined {
                    mutable.removeAttribute(.underlineStyle, range: range)
                } else {
                    mutable.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
                }
                textView.attributedText = mutable
                textView.selectedRange = range
                parent.attributedText = textView.attributedText
            } else {
                var typing = textView.typingAttributes
                if let style = typing[.underlineStyle] as? Int, style != 0 {
                    typing[.underlineStyle] = 0
                } else {
                    typing[.underlineStyle] = NSUnderlineStyle.single.rawValue
                }
                textView.typingAttributes = typing
            }
        }

        private func toggleTrait(_ trait: UIFontDescriptor.SymbolicTraits, in textView: UITextView) {
            let range = textView.selectedRange

            if range.length > 0 {
                let mutable = NSMutableAttributedString(attributedString: textView.attributedText)
                // Check if ALL characters in the range have the trait
                var allHaveTrait = true
                mutable.enumerateAttribute(.font, in: range) { value, _, _ in
                    guard let font = value as? UIFont,
                          font.fontDescriptor.symbolicTraits.contains(trait) else {
                        allHaveTrait = false
                        return
                    }
                }
                mutable.enumerateAttribute(.font, in: range) { value, subRange, _ in
                    let current = (value as? UIFont) ?? UIFont.preferredFont(forTextStyle: .body)
                    var traits = current.fontDescriptor.symbolicTraits
                    if allHaveTrait { traits.remove(trait) } else { traits.insert(trait) }
                    if let descriptor = current.fontDescriptor.withSymbolicTraits(traits) {
                        mutable.addAttribute(.font, value: UIFont(descriptor: descriptor, size: current.pointSize), range: subRange)
                    }
                }
                textView.attributedText = mutable
                textView.selectedRange = range
                parent.attributedText = textView.attributedText
            } else {
                var typing = textView.typingAttributes
                let current = (typing[.font] as? UIFont) ?? UIFont.preferredFont(forTextStyle: .body)
                var traits = current.fontDescriptor.symbolicTraits
                if traits.contains(trait) { traits.remove(trait) } else { traits.insert(trait) }
                if let descriptor = current.fontDescriptor.withSymbolicTraits(traits) {
                    typing[.font] = UIFont(descriptor: descriptor, size: current.pointSize)
                }
                textView.typingAttributes = typing
            }
        }
    }
}

// MARK: - NSAttributedString RTF helpers

extension NSAttributedString {
    func rtfData() -> Data? {
        guard length > 0 else { return nil }
        return try? data(
            from: NSRange(location: 0, length: length),
            documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]
        )
    }

    static func from(rtfData: Data) -> NSAttributedString? {
        try? NSAttributedString(
            data: rtfData,
            options: [.documentType: NSAttributedString.DocumentType.rtf],
            documentAttributes: nil
        )
    }
}
