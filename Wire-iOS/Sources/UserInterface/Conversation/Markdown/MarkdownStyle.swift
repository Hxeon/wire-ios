//
// Wire
// Copyright (C) 2017 Wire Swiss GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
//


import UIKit

struct Markdown: OptionSet, Hashable {
    
    let rawValue: Int
    var hashValue: Int { return self.rawValue }
    
    // atomic options
    
    static let none             = Markdown(rawValue: 0)
    static let header1          = Markdown(rawValue: 1 << 0)
    static let header2          = Markdown(rawValue: 1 << 1)
    static let header3          = Markdown(rawValue: 1 << 2)
    static let bold             = Markdown(rawValue: 1 << 3)
    static let italic           = Markdown(rawValue: 1 << 4)
    static let code             = Markdown(rawValue: 1 << 5)
    static let list             = Markdown(rawValue: 1 << 6)
    static let listPrefix       = Markdown(rawValue: 1 << 7)
    
    static let syntax           = Markdown(rawValue: 1 << 8)
    
    // combined options
    
    static let boldItalic:      Markdown = [.bold, .italic]
    static let listBold:        Markdown = [.list, .bold]
    static let listItalic:      Markdown = [.list, .italic]
    static let listBoldItalic:  Markdown = [.list, .boldItalic]
    static let listCode:        Markdown = [.list, .code]
    
    // values
    
    static let atomicValues: [Markdown] = [
        .header1, .header2, .header3, .bold, .italic, .code, .list, .listPrefix
    ]
    
    static let combinedValues: [Markdown] = [
        .boldItalic, .listBold, .listItalic, .listBoldItalic, .listCode
    ]
    
    static let validValues: [Markdown] = Markdown.atomicValues + Markdown.combinedValues
    
    // helpers
    
    var isValid: Bool {
        return Markdown.validValues.contains(self)
    }
    
    var isHeader: Bool {
        return [Markdown.header1, .header2, .header3].contains(self)
    }
    
    var isList: Bool {
        return self.contains(.list)
    }
}

let MarkdownAttributeName = "markdownKey"

typealias Attributes = [String : Any]

/// This class provides an interface to define a mapping between markdown
/// types and text attributes. By querying the value of the `markdown` key,
/// one can determine which markdown type a particular dictionary of attributes
/// corresponds to.
///
class MarkdownStyle: NSObject {
    
    static let inlineStyle: MarkdownStyle = {
        let defaultStyle = MarkdownStyle()
        let headerFont = UIFont.boldSystemFont(ofSize: 16)
        defaultStyle.header1Attributes[NSFontAttributeName] = headerFont
        defaultStyle.header2Attributes[NSFontAttributeName] = headerFont
        defaultStyle.header3Attributes[NSFontAttributeName] = headerFont
        return defaultStyle
    }()
    
    var defaultAttributes: Attributes = [
        MarkdownAttributeName: Markdown.none,
        NSForegroundColorAttributeName: ColorScheme.default().color(withName: ColorSchemeColorTextForeground),
        NSFontAttributeName: FontSpec(.normal, .none).font!,
    ]
    
    var header1Attributes: Attributes = [
        MarkdownAttributeName: Markdown.header1,
        NSFontAttributeName: UIFont.boldSystemFont(ofSize: 28)
    ]
    
    var header2Attributes: Attributes = [
        MarkdownAttributeName: Markdown.header2,
        NSFontAttributeName: UIFont.boldSystemFont(ofSize: 24)
    ]
    
    var header3Attributes: Attributes = [
        MarkdownAttributeName: Markdown.header3,
        NSFontAttributeName: UIFont.boldSystemFont(ofSize: 20)
    ]
    
    var boldAttributes: Attributes = [
        MarkdownAttributeName: Markdown.bold,
        NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16)
    ]
    
    var italicAttributes: Attributes = [
        MarkdownAttributeName: Markdown.italic,
        NSFontAttributeName: FontSpec(.normal, .none).font!.italicFont()
    ]
    
    var boldItalicAttributes: Attributes = [
        MarkdownAttributeName: Markdown.boldItalic,
        NSFontAttributeName: UIFont(name: "Helvetica-BoldOblique", size: 16)!
    ]
    
    var codeAttributes: Attributes = [
        MarkdownAttributeName: Markdown.code,
        NSFontAttributeName: UIFont(name: "Menlo", size: 16)!
    ]
    
    var listParagraphStyle: NSParagraphStyle = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = 4.0
        return paragraphStyle
    }()
    
    
    /// Returns the attributes associated with the given markdown bitmask.
    ///
    final func attributes(for markdown: Markdown) -> Attributes {
        switch markdown {
        case .header1:      return header1Attributes
        case .header2:      return header2Attributes
        case .header3:      return header3Attributes
        case .bold:         return boldAttributes
        case .italic:       return italicAttributes
        case .boldItalic:   return boldItalicAttributes
        case .code:         return codeAttributes
        case .list,
             .listPrefix,
             .listBold,
             .listItalic,
             .listBoldItalic,
             .listCode:     return listAttributes(for: markdown) ?? defaultAttributes
        default:            return defaultAttributes
        }
    }
    
    /// Returns the attributes for the given list markdown by first retrieving
    /// the attributes for the markdown minus the list option, then adding the list
    /// paragraph attribute. If the markdown doesn't contain the list option, then
    /// nil is returned.
    ///
    private func listAttributes(for markdown: Markdown) -> Attributes? {
        guard markdown.isValid, markdown.isList else { return nil }
        
        let nonListMarkdown = markdown.subtracting(.list)
        
        // update the attribtues
        var attrs = attributes(for: nonListMarkdown)
        attrs[MarkdownAttributeName] = markdown
        attrs[NSParagraphStyleAttributeName] = listParagraphStyle
        return attrs
    }
}

