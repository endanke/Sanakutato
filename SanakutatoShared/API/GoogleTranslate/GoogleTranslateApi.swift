//
//  GoogleTranslateApi.swift
//  SanakutatoShared
//
//  Created by Daniel Eke on 2020. 08. 26..
//

import Foundation
import SwiftSoup

class GoogleTranslateApi: DictionarySource {

    func fetchTranslation(term: Term) {

    }

    func parseTerms(input: String) -> [Term] {
        var result: [Term] = []
        do {
            let doc = try SwiftSoup.parse(input)
            let terms = try doc.getElementsByClass("gt-baf-term-text")
            try terms.forEach {
                if let text = try $0.children().first()?.text() {
                    result.append(Term(language: .english, text: text))
                }
            }
        } catch Exception.Error(_, let message) {
            print(message)
        } catch {
            print("error")
        }
        return result
    }

}
