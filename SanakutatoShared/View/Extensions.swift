//
//  Extensions.swift
//  SanakutatoShared
//
//  Created by Daniel Eke on 2020. 08. 29..
//

import SwiftUI

extension String {
    func convertHtml() -> NSAttributedString {
        guard let data = data(using: .utf8) else { return NSAttributedString() }

        if let attributedString = try? NSMutableAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil
            ) {
            /*
            attributedString.addAttributes(
                [
                    NSAttributedString.Key.font: NSFont.systemFont(ofSize: 16, weight: .light),
                    NSAttributedString.Key.foregroundColor: NSColor.labelColor
                ],
                range: NSRange( location: 0, length: attributedString.length)
            )
             */
            return attributedString
        } else {
            return NSAttributedString()
        }
    }
}
