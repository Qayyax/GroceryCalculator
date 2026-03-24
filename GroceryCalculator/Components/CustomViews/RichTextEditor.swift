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

        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = context.coordinator
        textView.addGestureRecognizer(tapGesture)

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
        underlineButton.setTitleTextAttributes(
            [.font: UIFont.systemFont(ofSize: 17), .underlineStyle: NSUnderlineStyle.single.rawValue],
            for: .normal
        )

        let divider = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        divider.width = 16

        // — Lists —
        let bulletButton = UIBarButtonItem(
            image: UIImage(systemName: "list.bullet"),
            style: .plain, target: coordinator,
            action: #selector(Coordinator.toggleBulletList)
        )
        let numberedButton = UIBarButtonItem(
            image: UIImage(systemName: "list.number"),
            style: .plain, target: coordinator,
            action: #selector(Coordinator.toggleNumberedList)
        )
        let checklistButton = UIBarButtonItem(
            image: UIImage(systemName: "checklist"),
            style: .plain, target: coordinator,
            action: #selector(Coordinator.toggleChecklist)
        )

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolbar.items = [boldButton, italicButton, underlineButton, divider, bulletButton, numberedButton, checklistButton, flexSpace]
        return toolbar
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, UITextViewDelegate, UIGestureRecognizerDelegate {

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
        ) -> Bool {
            return true
        }
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

            // Check if ALL paragraphs in range already have this exact list type
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

        // MARK: Checklist

        private static let unchecked = "☐"
        private static let checked   = "☑"

        @objc func toggleChecklist() {
            guard let textView else { return }
            let selectedRange = textView.selectedRange
            let nsText = textView.text as NSString
            let fullRange = nsText.paragraphRange(for: selectedRange)

            // Collect paragraph ranges (reverse order so insertions don't shift earlier ranges)
            var paraRanges: [NSRange] = []
            var pos = fullRange.location
            while pos < fullRange.location + fullRange.length {
                let r = nsText.paragraphRange(for: NSRange(location: pos, length: 0))
                paraRanges.append(r)
                pos = r.location + r.length
                if r.length == 0 { break }
            }

            let allHaveChecklist = paraRanges.allSatisfy { r in
                let t = nsText.substring(with: r)
                return t.hasPrefix(Coordinator.unchecked) || t.hasPrefix(Coordinator.checked)
            }

            let mutable = NSMutableAttributedString(attributedString: textView.attributedText)

            for paraRange in paraRanges.reversed() {
                let paraText = (mutable.string as NSString).substring(with: paraRange)

                if allHaveChecklist {
                    // Remove "☐ " or "☑ " prefix
                    var removeLen = 0
                    if paraText.hasPrefix(Coordinator.unchecked) || paraText.hasPrefix(Coordinator.checked) {
                        removeLen = 1
                        if paraText.count > 1 {
                            let secondIdx = paraText.index(paraText.startIndex, offsetBy: 1)
                            if String(paraText[secondIdx]) == " " { removeLen = 2 }
                        }
                    }
                    if removeLen > 0 {
                        mutable.deleteCharacters(in: NSRange(location: paraRange.location, length: removeLen))
                    }
                    let newParaRange = (mutable.string as NSString).paragraphRange(for: NSRange(location: paraRange.location, length: 0))
                    mutable.enumerateAttribute(.paragraphStyle, in: newParaRange) { value, sub, _ in
                        let style = (value as? NSParagraphStyle)?.mutableCopy() as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
                        style.headIndent = 0
                        style.firstLineHeadIndent = 0
                        mutable.addAttribute(.paragraphStyle, value: style, range: sub)
                    }
                } else {
                    // Add "☐ " prefix if not already a checklist item
                    if !paraText.hasPrefix(Coordinator.unchecked) && !paraText.hasPrefix(Coordinator.checked) {
                        let attrs: [NSAttributedString.Key: Any] = paraRange.length > 0
                            ? mutable.attributes(at: paraRange.location, effectiveRange: nil)
                            : [.font: UIFont.preferredFont(forTextStyle: .body)]
                        mutable.insert(NSAttributedString(string: "\(Coordinator.unchecked) ", attributes: attrs), at: paraRange.location)
                    }
                    let newParaRange = (mutable.string as NSString).paragraphRange(for: NSRange(location: paraRange.location, length: 0))
                    mutable.enumerateAttribute(.paragraphStyle, in: newParaRange) { value, sub, _ in
                        let style = (value as? NSParagraphStyle)?.mutableCopy() as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
                        style.headIndent = 22
                        style.firstLineHeadIndent = 0
                        mutable.addAttribute(.paragraphStyle, value: style, range: sub)
                    }
                }
            }

            textView.attributedText = mutable
            textView.selectedRange = NSRange(location: min(selectedRange.location, mutable.length), length: 0)
            parent.attributedText = textView.attributedText
        }

        /// Tap recognizer: tapping a ☐/☑ character toggles it checked/unchecked.
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let textView else { return }
            let tapLocation = gesture.location(in: textView)

            guard let tapPosition = textView.closestPosition(to: tapLocation) else { return }
            let offset = textView.offset(from: textView.beginningOfDocument, to: tapPosition)
            let nsText = textView.text as NSString

            // Check the character at `offset` and `offset - 1` (closestPosition can land
            // either before or after the tapped glyph depending on tap x-position)
            for idx in [offset, offset - 1] {
                guard idx >= 0 && idx < nsText.length else { continue }
                let char = nsText.substring(with: NSRange(location: idx, length: 1))
                guard char == Coordinator.unchecked || char == Coordinator.checked else { continue }

                let isChecking = (char == Coordinator.unchecked)
                let newCheckbox = isChecking ? Coordinator.checked : Coordinator.unchecked
                let mutable = NSMutableAttributedString(attributedString: textView.attributedText)

                // Swap checkbox character (preserve its attributes)
                let checkboxAttrs = mutable.attributes(at: idx, effectiveRange: nil)
                mutable.replaceCharacters(
                    in: NSRange(location: idx, length: 1),
                    with: NSAttributedString(string: newCheckbox, attributes: checkboxAttrs)
                )

                // Apply / remove strikethrough on the line content after "☐ " / "☑ "
                let paraRange = nsText.paragraphRange(for: NSRange(location: idx, length: 0))
                let contentStart = idx + 2 // skip checkbox + space
                let paraEnd = paraRange.location + paraRange.length
                let hasNewline = paraEnd > 0 && nsText.character(at: paraEnd - 1) == unichar(("\n" as UnicodeScalar).value)
                let contentEnd = paraEnd - (hasNewline ? 1 : 0)

                if contentStart < contentEnd {
                    let contentRange = NSRange(location: contentStart, length: contentEnd - contentStart)
                    if isChecking {
                        mutable.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: contentRange)
                        mutable.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: contentRange)
                    } else {
                        mutable.removeAttribute(.strikethroughStyle, range: contentRange)
                        mutable.removeAttribute(.foregroundColor, range: contentRange)
                    }
                }

                textView.attributedText = mutable
                parent.attributedText = textView.attributedText
                return
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
