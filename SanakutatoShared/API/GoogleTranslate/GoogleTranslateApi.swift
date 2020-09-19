//
//  GoogleTranslateApi.swift
//  SanakutatoShared
//
//  Created by Daniel Eke on 2020. 08. 26..
//

import Foundation
import Combine
import SwiftSoup

class GoogleTranslateApi: DictionarySource {

    func fetchTranslation(term: Term) -> Future<String, Never> {
        return Future<String, Never> { _ in }
    }

    func parseTerms(input: String) {
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
        self.translatedTerms = result
    }

}
