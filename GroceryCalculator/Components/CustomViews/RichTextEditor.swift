//
//  RichTextEditor.swift
//  GroceryCalculator
//
//  Created by Abdul-Qayyum Olatunji on 2026-03-23.
//

import SwiftUI
import UIKit

// MARK: - CheckboxAttachment

/// NSTextAttachment rendered as an SF Symbol circle.
/// Persists `isChecked` via NSCoding for NSKeyedArchiver round-trips.
final class CheckboxAttachment: NSTextAttachment {

    var isChecked: Bool = false

    // Explicit designated-init override so the convenience init can delegate here
    override init(data contentData: Data?, ofType uti: String?) {
        super.init(data: contentData, ofType: uti)
    }

    convenience init(isChecked: Bool, font: UIFont) {
        self.init(data: nil, ofType: nil)
        self.isChecked = isChecked
        refreshImage(font: font)
    }

    func refreshImage(font: UIFont) {
        let config = UIImage.SymbolConfiguration(pointSize: font.pointSize, weight: .regular)
        let name:  String   = isChecked ? "checkmark.circle.fill" : "circle"
        let color: UIColor  = isChecked ? .systemGreen : .secondaryLabel
        image = UIImage(systemName: name, withConfiguration: config)?
            .withTintColor(color, renderingMode: .alwaysOriginal)
    }

    // Center symbol on cap-height rather than sitting on baseline
    override func attachmentBounds(
        for textContainer: NSTextContainer?,
        proposedLineFragment lineFrag: CGRect,
        glyphPosition position: CGPoint,
        characterIndex charIndex: Int
    ) -> CGRect {
        guard let img = image else { return .zero }
        let font = UIFont.preferredFont(forTextStyle: .body)
        let y = (font.capHeight - img.size.height) / 2
        return CGRect(x: 0, y: y, width: img.size.width, height: img.size.height)
    }

    // NSCoding — required for NSKeyedArchiver to preserve state across save/load
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        isChecked = coder.decodeBool(forKey: "isChecked")
        refreshImage(font: UIFont.preferredFont(forTextStyle: .body))
    }
    override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(isChecked, forKey: "isChecked")
    }
}

// MARK: - RichTextEditor

struct RichTextEditor: UIViewRepresentable {
    @Binding var attributedText: NSAttributedString
    var autoFocus: Bool = false

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.allowsEditingTextAttributes = true
        tv.backgroundColor = .clear
        tv.delegate = context.coordinator
        context.coordinator.textView = tv

        let font = UIFont.preferredFont(forTextStyle: .body)
        tv.font = font
        tv.typingAttributes = [.font: font, .foregroundColor: UIColor.label]

        if autoFocus {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { tv.becomeFirstResponder() }
        }

        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        tap.cancelsTouchesInView = false
        tap.delegate = context.coordinator
        tv.addGestureRecognizer(tap)

        tv.inputAccessoryView = makeToolbar(coordinator: context.coordinator)
        return tv
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        guard !uiView.isFirstResponder else { return }
        uiView.attributedText = attributedText
    }

    private func makeToolbar(coordinator: Coordinator) -> UIToolbar {
        let bar = UIToolbar()
        bar.sizeToFit()

        let bold = barButton("B", font: .boldSystemFont(ofSize: 17),   target: coordinator, action: #selector(Coordinator.toggleBold))
        let italic = barButton("I", font: .italicSystemFont(ofSize: 17), target: coordinator, action: #selector(Coordinator.toggleItalic))
        let underline = barButton("U", font: .systemFont(ofSize: 17),    target: coordinator, action: #selector(Coordinator.toggleUnderline),
                                  extraAttrs: [.underlineStyle: NSUnderlineStyle.single.rawValue])

        let gap = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        gap.width = 16

        let bullet    = imageButton("list.bullet",  target: coordinator, action: #selector(Coordinator.toggleBulletList))
        let numbered  = imageButton("list.number",  target: coordinator, action: #selector(Coordinator.toggleNumberedList))
        let checklist = imageButton("checklist",    target: coordinator, action: #selector(Coordinator.toggleChecklist))
        let flex      = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        bar.items = [bold, italic, underline, gap, bullet, numbered, checklist, flex]
        return bar
    }

    private func barButton(_ title: String, font: UIFont, target: AnyObject, action: Selector,
                           extraAttrs: [NSAttributedString.Key: Any] = [:]) -> UIBarButtonItem {
        let b = UIBarButtonItem(title: title, style: .plain, target: target, action: action)
        var attrs: [NSAttributedString.Key: Any] = [.font: font]
        attrs.merge(extraAttrs) { $1 }
        b.setTitleTextAttributes(attrs, for: .normal)
        return b
    }

    private func imageButton(_ systemName: String, target: AnyObject, action: Selector) -> UIBarButtonItem {
        UIBarButtonItem(image: UIImage(systemName: systemName), style: .plain, target: target, action: action)
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, UITextViewDelegate, UIGestureRecognizerDelegate {

        var parent: RichTextEditor
        weak var textView: UITextView?

        init(_ parent: RichTextEditor) { self.parent = parent }

        func gestureRecognizer(_ gr: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool { true }

        func textViewDidChange(_ textView: UITextView) {
            parent.attributedText = textView.attributedText
        }

        // MARK: Enter-key handling (list continuation / exit)

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            // Only intercept a plain newline with no selected text
            guard text == "\n", range.length == 0, !textView.text.isEmpty else { return true }

            let nsText        = textView.text as NSString
            let currentPara   = nsText.paragraphRange(for: range)
            guard currentPara.length > 0,
                  currentPara.location < textView.attributedText.length else { return true }

            let font = (textView.typingAttributes[.font] as? UIFont) ?? UIFont.preferredFont(forTextStyle: .body)

            // ── Checklist ──
            if textView.attributedText.attribute(.attachment, at: currentPara.location, effectiveRange: nil) is CheckboxAttachment {
                let paraText    = nsText.substring(with: currentPara)
                let contentOnly = paraText
                    .replacingOccurrences(of: "\u{FFFC}", with: "")   // object-replacement char (attachment)
                    .replacingOccurrences(of: "\t", with: "")
                    .trimmingCharacters(in: .newlines)

                let m = NSMutableAttributedString(attributedString: textView.attributedText)

                if contentOnly.isEmpty {
                    // Empty checklist item → exit list (remove checkbox, no newline)
                    removeCheckboxPrefix(from: currentPara.location, in: m, font: font)
                    textView.attributedText = m
                    textView.selectedRange  = NSRange(location: currentPara.location, length: 0)
                } else {
                    // Continue: insert \n + new checkbox item
                    let indent   = checklistIndent(for: font)
                    let toInsert = newChecklistItem(font: font, indent: indent)
                    m.insert(NSAttributedString(string: "\n", attributes: [.font: font]), at: range.location)
                    m.insert(toInsert, at: range.location + 1)
                    textView.attributedText = m
                    textView.selectedRange  = NSRange(location: range.location + 3, length: 0) // after \n + attach + tab
                }

                parent.attributedText = textView.attributedText
                return false
            }

            // ── Bullet / Numbered list ──
            if let style = textView.attributedText.attribute(.paragraphStyle, at: currentPara.location, effectiveRange: nil) as? NSParagraphStyle,
               !style.textLists.isEmpty {

                let paraText    = nsText.substring(with: currentPara)
                let contentOnly = paraText.trimmingCharacters(in: .whitespacesAndNewlines)

                if contentOnly.isEmpty {
                    // Empty list item → exit list (remove list style, no newline)
                    let m = NSMutableAttributedString(attributedString: textView.attributedText)
                    resetListStyle(in: currentPara, on: m)
                    textView.attributedText = m
                    // Also clear typing attributes so the next character isn't in a list
                    var typing = textView.typingAttributes
                    if let s = (typing[.paragraphStyle] as? NSParagraphStyle)?.mutableCopy() as? NSMutableParagraphStyle {
                        s.textLists = []; s.headIndent = 0; s.firstLineHeadIndent = 0
                        typing[.paragraphStyle] = s
                    }
                    textView.typingAttributes = typing
                    textView.selectedRange    = NSRange(location: range.location, length: 0)
                    parent.attributedText     = textView.attributedText
                    return false
                }
                // Non-empty: UITextView propagates paragraph style (including NSTextList) automatically
                return true
            }

            return true
        }

        // MARK: Bold / Italic / Underline

        @objc func toggleBold()   { guard let tv = textView else { return }; toggleTrait(.traitBold,   in: tv) }
        @objc func toggleItalic() { guard let tv = textView else { return }; toggleTrait(.traitItalic, in: tv) }

        @objc func toggleUnderline() {
            guard let tv = textView else { return }
            let range = tv.selectedRange
            if range.length > 0 {
                let m = NSMutableAttributedString(attributedString: tv.attributedText)
                var allHave = true
                m.enumerateAttribute(.underlineStyle, in: range) { v, _, _ in
                    if let s = v as? Int, s != 0 { return }; allHave = false
                }
                if allHave { m.removeAttribute(.underlineStyle, range: range) }
                else        { m.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range) }
                tv.attributedText = m; tv.selectedRange = range; parent.attributedText = m
            } else {
                var t = tv.typingAttributes
                if let s = t[.underlineStyle] as? Int, s != 0 { t[.underlineStyle] = 0 }
                else { t[.underlineStyle] = NSUnderlineStyle.single.rawValue }
                tv.typingAttributes = t
            }
        }

        private func toggleTrait(_ trait: UIFontDescriptor.SymbolicTraits, in tv: UITextView) {
            let range = tv.selectedRange
            if range.length > 0 {
                let m = NSMutableAttributedString(attributedString: tv.attributedText)
                var allHave = true
                m.enumerateAttribute(.font, in: range) { v, _, _ in
                    guard let f = v as? UIFont, f.fontDescriptor.symbolicTraits.contains(trait) else { allHave = false; return }
                }
                m.enumerateAttribute(.font, in: range) { v, sub, _ in
                    let cur = (v as? UIFont) ?? UIFont.preferredFont(forTextStyle: .body)
                    var t = cur.fontDescriptor.symbolicTraits
                    if allHave { t.remove(trait) } else { t.insert(trait) }
                    if let d = cur.fontDescriptor.withSymbolicTraits(t) {
                        m.addAttribute(.font, value: UIFont(descriptor: d, size: cur.pointSize), range: sub)
                    }
                }
                tv.attributedText = m; tv.selectedRange = range; parent.attributedText = m
            } else {
                var t   = tv.typingAttributes
                let cur = (t[.font] as? UIFont) ?? UIFont.preferredFont(forTextStyle: .body)
                var traits = cur.fontDescriptor.symbolicTraits
                if traits.contains(trait) { traits.remove(trait) } else { traits.insert(trait) }
                if let d = cur.fontDescriptor.withSymbolicTraits(traits) { t[.font] = UIFont(descriptor: d, size: cur.pointSize) }
                tv.typingAttributes = t
            }
        }

        // MARK: Bullet / Numbered lists

        @objc func toggleBulletList()   { guard let tv = textView else { return }; toggleList(.disc,    in: tv) }
        @objc func toggleNumberedList() { guard let tv = textView else { return }; toggleList(.decimal, in: tv) }

        private func toggleList(_ markerFormat: NSTextList.MarkerFormat, in tv: UITextView) {
            let sel       = tv.selectedRange
            let paraRange = (tv.text as NSString).paragraphRange(for: sel)
            let m         = NSMutableAttributedString(attributedString: tv.attributedText)

            var allHave = true
            m.enumerateAttribute(.paragraphStyle, in: paraRange) { v, _, stop in
                guard let s = v as? NSParagraphStyle, s.textLists.first?.markerFormat == markerFormat
                else { allHave = false; stop.pointee = true; return }
            }

            let list = NSTextList(markerFormat: markerFormat, options: 0)
            list.startingItemNumber = 1

            // Apply to any text in the selection
            if paraRange.length > 0 {
                m.enumerateAttribute(.paragraphStyle, in: paraRange) { v, sub, _ in
                    applyListStyle(allHave: allHave, list: list, to: v, in: sub, on: m)
                }
                tv.attributedText = m
                tv.selectedRange  = sel
            }

            // Always sync typing attributes — critical for clicking the button on an empty line
            var typing = tv.typingAttributes
            let ts = (typing[.paragraphStyle] as? NSParagraphStyle)?.mutableCopy() as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
            if allHave { ts.textLists = []; ts.headIndent = 0; ts.firstLineHeadIndent = 0 }
            else        { ts.textLists = [list]; ts.firstLineHeadIndent = 16; ts.headIndent = 32 }
            typing[.paragraphStyle] = ts
            tv.typingAttributes = typing

            parent.attributedText = tv.attributedText
        }

        private func applyListStyle(allHave: Bool, list: NSTextList, to value: Any?, in range: NSRange, on m: NSMutableAttributedString) {
            let s = (value as? NSParagraphStyle)?.mutableCopy() as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
            if allHave { s.textLists = []; s.headIndent = 0; s.firstLineHeadIndent = 0 }
            else        { s.textLists = [list]; s.firstLineHeadIndent = 16; s.headIndent = 32 }
            m.addAttribute(.paragraphStyle, value: s, range: range)
        }

        // MARK: Checklist

        @objc func toggleChecklist() {
            guard let tv = textView else { return }
            let sel    = tv.selectedRange
            let nsText = tv.text as NSString
            let full   = nsText.paragraphRange(for: sel)
            let font   = (tv.typingAttributes[.font] as? UIFont) ?? UIFont.preferredFont(forTextStyle: .body)

            var paraRanges: [NSRange] = []
            var pos = full.location
            while pos < full.location + full.length {
                let r = nsText.paragraphRange(for: NSRange(location: pos, length: 0))
                paraRanges.append(r)
                pos = r.location + r.length
                if r.length == 0 { break }
            }

            let allHave = paraRanges.allSatisfy { r in
                guard r.length > 0, r.location < tv.attributedText.length else { return false }
                return tv.attributedText.attribute(.attachment, at: r.location, effectiveRange: nil) is CheckboxAttachment
            }

            let m = NSMutableAttributedString(attributedString: tv.attributedText)

            for r in paraRanges.reversed() {
                if allHave {
                    removeCheckboxPrefix(from: r.location, in: m, font: font)
                } else {
                    guard !(r.length > 0 && r.location < m.length &&
                            m.attribute(.attachment, at: r.location, effectiveRange: nil) is CheckboxAttachment)
                    else { continue }

                    let indent = checklistIndent(for: font)
                    let prefix = newChecklistItem(font: font, indent: indent)
                    m.insert(prefix, at: r.location)

                    // Apply indentation to the whole paragraph
                    let newParaRange = (m.string as NSString).paragraphRange(for: NSRange(location: r.location, length: 0))
                    m.enumerateAttribute(.paragraphStyle, in: newParaRange) { v, sub, _ in
                        let s = (v as? NSParagraphStyle)?.mutableCopy() as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
                        s.firstLineHeadIndent = 0; s.headIndent = indent
                        s.tabStops = [NSTextTab(textAlignment: .left, location: indent)]
                        m.addAttribute(.paragraphStyle, value: s, range: sub)
                    }
                }
            }

            tv.attributedText = m

            if !allHave, let first = paraRanges.first {
                // Place cursor after [attachment][tab] so user can type immediately
                tv.selectedRange = NSRange(location: min(first.location + 2, m.length), length: 0)
            } else {
                tv.selectedRange = NSRange(location: min(sel.location, m.length), length: 0)
            }

            parent.attributedText = tv.attributedText
        }

        // MARK: Tap — toggle checkbox on/off

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let tv = textView else { return }
            let tapPt  = gesture.location(in: tv)
            guard let pos = tv.closestPosition(to: tapPt) else { return }
            let offset = tv.offset(from: tv.beginningOfDocument, to: pos)
            let len    = tv.attributedText.length
            let nsText = tv.text as NSString

            for idx in [offset, offset - 1] {
                guard idx >= 0 && idx < len else { continue }
                guard let box = tv.attributedText.attribute(.attachment, at: idx, effectiveRange: nil) as? CheckboxAttachment else { continue }

                let font = tv.attributedText.attribute(.font, at: idx, effectiveRange: nil) as? UIFont
                    ?? UIFont.preferredFont(forTextStyle: .body)

                box.isChecked.toggle()
                box.refreshImage(font: font)

                let m = NSMutableAttributedString(attributedString: tv.attributedText)
                // Rebuild the attachment character to force layout refresh
                let repl = NSMutableAttributedString(attachment: box)
                tv.attributedText.attributes(at: idx, effectiveRange: nil).forEach { key, val in
                    if key != .attachment { repl.addAttribute(key, value: val, range: NSRange(location: 0, length: 1)) }
                }
                m.replaceCharacters(in: NSRange(location: idx, length: 1), with: repl)

                // Strikethrough + dim the text content after [attachment][tab]
                let para         = nsText.paragraphRange(for: NSRange(location: idx, length: 0))
                let contentStart = idx + 2
                let paraEnd      = para.location + para.length
                let trimNewline  = paraEnd > 0 && nsText.character(at: paraEnd - 1) == unichar(("\n" as UnicodeScalar).value)
                let contentEnd   = paraEnd - (trimNewline ? 1 : 0)

                if contentStart < contentEnd {
                    let cr = NSRange(location: contentStart, length: contentEnd - contentStart)
                    if box.isChecked {
                        m.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: cr)
                        m.addAttribute(.foregroundColor, value: UIColor.tertiaryLabel, range: cr)
                    } else {
                        m.removeAttribute(.strikethroughStyle, range: cr)
                        m.removeAttribute(.foregroundColor,    range: cr)
                    }
                }

                tv.attributedText = m
                parent.attributedText = m
                return
            }
        }

        // MARK: Private helpers

        private func checklistIndent(for font: UIFont) -> CGFloat { ceil(font.pointSize) + 8 }

        private func newChecklistItem(font: UIFont, indent: CGFloat) -> NSMutableAttributedString {
            let style = NSMutableParagraphStyle()
            style.firstLineHeadIndent = 0
            style.headIndent          = indent
            style.tabStops            = [NSTextTab(textAlignment: .left, location: indent)]

            let box    = CheckboxAttachment(isChecked: false, font: font)
            let result = NSMutableAttributedString(attachment: box)
            result.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: 1))
            result.append(NSAttributedString(string: "\t", attributes: [.font: font, .paragraphStyle: style]))
            return result
        }

        private func removeCheckboxPrefix(from location: Int, in m: NSMutableAttributedString, font: UIFont) {
            guard location < m.length,
                  m.attribute(.attachment, at: location, effectiveRange: nil) is CheckboxAttachment
            else { return }

            var removeLen = 1
            if location + 1 < m.length,
               (m.string as NSString).character(at: location + 1) == unichar(("\t" as UnicodeScalar).value) {
                removeLen = 2
            }
            m.deleteCharacters(in: NSRange(location: location, length: removeLen))

            let newR = (m.string as NSString).paragraphRange(for: NSRange(location: location, length: 0))
            if newR.length > 0 {
                m.enumerateAttribute(.paragraphStyle, in: newR) { v, sub, _ in
                    let s = (v as? NSParagraphStyle)?.mutableCopy() as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
                    s.headIndent = 0; s.firstLineHeadIndent = 0; s.tabStops = []
                    m.addAttribute(.paragraphStyle, value: s, range: sub)
                }
            }
        }

        private func resetListStyle(in range: NSRange, on m: NSMutableAttributedString) {
            guard range.length > 0 else { return }
            m.enumerateAttribute(.paragraphStyle, in: range) { v, sub, _ in
                let s = (v as? NSParagraphStyle)?.mutableCopy() as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
                s.textLists = []; s.headIndent = 0; s.firstLineHeadIndent = 0
                m.addAttribute(.paragraphStyle, value: s, range: sub)
            }
        }
    }
}

// MARK: - NSAttributedString archive helpers

extension NSAttributedString {
    /// Encodes using NSKeyedArchiver, preserving CheckboxAttachment and all custom attributes.
    func encoded() -> Data? {
        guard length > 0 else { return nil }
        return try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }

    static func decoded(from data: Data) -> NSAttributedString? {
        guard let u = try? NSKeyedUnarchiver(forReadingFrom: data) else { return nil }
        u.requiresSecureCoding = false
        return u.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? NSAttributedString
    }
}
