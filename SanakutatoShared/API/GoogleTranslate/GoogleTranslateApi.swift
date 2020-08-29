//
//  GoogleTranslateApi.swift
//  SanakutatoShared
//
//  Created by Daniel Eke on 2020. 08. 26..
//

import Foundation
import SwiftSoup

class GoogleTranslateApi {

    func parseTerms(input: String) {
        do {
            let doc = try SwiftSoup.parse(input)
            let terms = try doc.getElementsByClass("gt-baf-term-text")
            try terms.forEach {
                let text = try $0.children().first()?.text()
                print(text ?? "")
            }
        } catch Exception.Error(_, let message) {
            print(message)
        } catch {
            print("error")
        }
    }

}
