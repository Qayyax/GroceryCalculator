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

        // — Text style —
        let boldButton = UIBarButtonItem(title: "B", style: .plain, target: coordinator, action: #selector(Coordinator.toggleBold))
        boldButton.setTitleTextAttributes([.font: UIFont.boldSystemFont(ofSize: 17)], for: .normal)

        let italicButton = UIBarButtonItem(title: "I", style: .plain, target: coordinator, action: #selector(Coordinator.toggleItalic))
        italicButton.setTitleTextAttributes([.font: UIFont.italicSystemFont(ofSize: 17)], for: .normal)

        let underlineButton = UIBarButtonItem(title: "U", style: .plain, target: coordinator, action: #selector(Coordinator.toggleUnderline))
        underlineButton.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 17), .underlineStyle: NSUnderlineStyle.single.rawValue], for: .normal)

        let divider = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        divider.width = 16

        // — Lists —
        let bulletButton = UIBarButtonItem(
            image: UIImage(systemName: "list.bullet"),
            style: .plain,
            target: coordinator,
            action: #selector(Coordinator.toggleBulletList)
        )

        let numberedButton = UIBarButtonItem(
            image: UIImage(systemName: "list.number"),
            style: .plain,
            target: coordinator,
            action: #selector(Coordinator.toggleNumberedList)
        )

        let divider2 = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        divider2.width = 16

        // — Table —
        let tableButton = UIBarButtonItem(
            image: UIImage(systemName: "tablecells"),
            style: .plain,
            target: coordinator,
            action: #selector(Coordinator.insertTableTapped)
        )

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolbar.items = [boldButton, italicButton, underlineButton, divider, bulletButton, numberedButton, divider2, tableButton, flexSpace]
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

        // MARK: Bold / Italic / Underline

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

        // MARK: Lists

        @objc func toggleBulletList() {
            guard let textView else { return }
            toggleList(markerFormat: .disc, in: textView)
        }

        @objc func toggleNumberedList() {
            guard let textView else { return }
            toggleList(markerFormat: .decimal, in: textView)
        }

        private func toggleList(markerFormat: NSTextList.MarkerFormat, in textView: UITextView) {
            let selectedRange = textView.selectedRange
            let paragraphRange = (textView.text as NSString).paragraphRange(for: selectedRange)
            let mutable = NSMutableAttributedString(attributedString: textView.attributedText)

            // Check if ALL paragraphs in the range already have this exact list type
            var allHaveList = true
            mutable.enumerateAttribute(.paragraphStyle, in: paragraphRange) { value, _, stop in
                guard let style = value as? NSParagraphStyle,
                      style.textLists.first?.markerFormat == markerFormat else {
                    allHaveList = false
                    stop.pointee = true
                    return
                }
            }

            // One shared instance so numbered lists count sequentially across paragraphs
            let list = NSTextList(markerFormat: markerFormat, options: 0)
            list.startingItemNumber = 1

            mutable.enumerateAttribute(.paragraphStyle, in: paragraphRange) { value, subRange, _ in
                // Preserve existing paragraph properties (alignment, spacing, etc.)
                let style = (value as? NSParagraphStyle)?.mutableCopy() as? NSMutableParagraphStyle
                    ?? NSMutableParagraphStyle()
                if allHaveList {
                    style.textLists = []
                    style.headIndent = 0
                    style.firstLineHeadIndent = 0
                } else {
                    style.textLists = [list]
                    style.firstLineHeadIndent = 16
                    style.headIndent = 32
                }
                mutable.addAttribute(.paragraphStyle, value: style, range: subRange)
            }

            textView.attributedText = mutable
            textView.selectedRange = selectedRange
            parent.attributedText = textView.attributedText
        }

        // MARK: Tables

        @objc func insertTableTapped() {
            guard let textView, let vc = topmostViewController() else { return }

            let alert = UIAlertController(title: "Insert Table", message: nil, preferredStyle: .alert)
            alert.addTextField { tf in
                tf.placeholder = "Rows"
                tf.text = "2"
                tf.keyboardType = .numberPad
            }
            alert.addTextField { tf in
                tf.placeholder = "Columns"
                tf.text = "2"
                tf.keyboardType = .numberPad
            }
            alert.addAction(UIAlertAction(title: "Insert", style: .default) { [weak self] _ in
                let rows = max(1, min(Int(alert.textFields?[0].text ?? "") ?? 2, 10))
                let cols = max(1, min(Int(alert.textFields?[1].text ?? "") ?? 2, 6))
                self?.insertTable(rows: rows, columns: cols, in: textView)
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            vc.present(alert, animated: true)
        }

        /// Inserts a Unicode box-drawing table rendered in a monospace font.
        /// NSTextTable/NSTextTableBlock are macOS-only and not available on iOS.
        private func insertTable(rows: Int, columns: Int, in textView: UITextView) {
            let bodySize = UIFont.preferredFont(forTextStyle: .body).pointSize
            let monoFont = UIFont.monospacedSystemFont(ofSize: bodySize, weight: .regular)

            // Calculate how many characters fit per column based on the text view width
            let insets = textView.textContainerInset
            let padding = textView.textContainer.lineFragmentPadding
            let viewWidth = textView.bounds.width - insets.left - insets.right - 2 * padding
            let charWidth = ("─" as NSString).size(withAttributes: [.font: monoFont]).width
            let totalAvailableChars = charWidth > 0 ? Int(viewWidth / charWidth) : (columns * 12)
            // Subtract border chars (one | per column plus the outer |)
            let cellWidth = max(4, (totalAvailableChars - (columns + 1)) / columns)

            func hLine(left: String, mid: String, right: String, fill: String) -> String {
                let segment = String(repeating: fill, count: cellWidth)
                return left + (0..<columns).map { _ in segment }.joined(separator: mid) + right + "\n"
            }

            var tableText = ""
            tableText += hLine(left: "┌", mid: "┬", right: "┐", fill: "─")
            for row in 0..<rows {
                let cellContent = String(repeating: " ", count: cellWidth)
                tableText += "│" + (0..<columns).map { _ in cellContent }.joined(separator: "│") + "│\n"
                if row < rows - 1 {
                    tableText += hLine(left: "├", mid: "┼", right: "┤", fill: "─")
                }
            }
            tableText += hLine(left: "└", mid: "┴", right: "┘", fill: "─")

            let baseFont = (textView.typingAttributes[.font] as? UIFont) ?? UIFont.preferredFont(forTextStyle: .body)
            let tableAttr = NSAttributedString(string: tableText, attributes: [.font: monoFont])

            let insertLocation = textView.selectedRange.location
            let fullText = textView.text as NSString
            let needsLeadingBreak = insertLocation > 0
                && fullText.character(at: insertLocation - 1) != unichar(("\n" as UnicodeScalar).value)

            let toInsert = NSMutableAttributedString()
            if needsLeadingBreak {
                toInsert.append(NSAttributedString(string: "\n", attributes: [.font: baseFont]))
            }
            toInsert.append(tableAttr)

            let existing = NSMutableAttributedString(attributedString: textView.attributedText)
            existing.insert(toInsert, at: insertLocation)
            textView.attributedText = existing

            // Place cursor at the first cell's content (after top border row + first │)
            // Top border length: 1(┌) + cellWidth*columns + (columns-1)(┬s) + 1(┐) + 1(\n)
            let topRowLen = 1 + cellWidth * columns + (columns - 1) + 1 + 1
            let firstCellPos = insertLocation + (needsLeadingBreak ? 1 : 0) + topRowLen + 1
            textView.selectedRange = NSRange(location: min(firstCellPos, existing.length), length: 0)
            parent.attributedText = textView.attributedText
        }

        // Walk the responder chain to find the topmost presented UIViewController
        private func topmostViewController() -> UIViewController? {
            guard var vc = textView?.window?.rootViewController else { return nil }
            while let presented = vc.presentedViewController { vc = presented }
            return vc
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
