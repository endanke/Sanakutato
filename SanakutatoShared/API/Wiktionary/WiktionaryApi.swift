//
//  WiktionaryApi.swift
//  SanakutatoShared
//
//  Created by Daniel Eke on 2020. 08. 29..
//

import Foundation
import Combine
import SwiftSoup

enum WiktionarySection: String {
    case etymology
    case pronunciation
    case synonyms
    case noun
}

/**
 * Fetches and parses content from Wiktionary.
 * Since the data  is mostly unstructured, there's some heuristic manual configuration
 * in the parser's setup. Some of it is based on this solution:
 * https://github.com/Suyash458/WiktionaryParser/blob/master/wiktionaryparser.py
 */
class WiktionaryApi: DictionarySource {

    private let partOfSpeech = [
        "noun", "verb", "adjective", "adverb", "determiner",
        "article", "preposition", "conjunction", "proper noun",
        "letter", "character", "phrase", "proverb", "idiom",
        "symbol", "syllable", "numeral", "initialism", "interjection",
        "definitions", "pronoun", "particle", "predicative", "participle",
        "suffix"
    ]

    private let relations = [
        "synonyms", "antonyms", "hypernyms", "hyponyms",
        "meronyms", "holonyms", "troponyms", "related terms",
        "coordinate terms"
    ]

    var result: [WiktionarySection: String] = [:]
    var completeLanguage = ""

    private func buildUrl(from term: Term) -> URL {
        guard let url = URL(string: "https://en.wiktionary.org/wiki/\(term.text)?printable=yes") else {
            fatalError("Failed to build URL")
        }
        return url
    }

    private func parseContent(source: String) throws {
        let doc = try SwiftSoup.parse(source)
        let contents = try doc.getElementsByClass("toctext")
        var indexPrefix: String?
        var targetSections: [Element] = []
        // Find the root index for the target language in the TOC (if exists)
        for content in contents {
            if try content.text().lowercased() == "finnish",
                let indexFromSibling = try content.firstElementSibling()?.text() {
                indexPrefix = "\(indexFromSibling)."
            }
        }
        // Find all related sections based on the target root index
        for content in contents {
            if let indexFromSibling = try content.firstElementSibling()?.text(),
                let prefix = indexPrefix,
                indexFromSibling.starts(with: prefix),
                let hrefContent = try content.parent()?.attr("href") {
                targetSections.append(content)
                let text = try content.text().lowercased()
                let sectionId = String(hrefContent.dropFirst())
                if let section = WiktionarySection(rawValue: text) {
                    switch section {
                    case .etymology: try parseEtymology(doc, sectionId)
                    case .pronunciation: parsePronunciation()
                    case .synonyms: parseSynonyms()
                    case .noun: try parseNoun(doc, sectionId)
                    }
                }
            }
        }
        print(targetSections)
        try parseCompleteLanguage(doc)
    }

    private func parseCompleteLanguage(_ doc: Document) throws {
        let sectionStart = try doc.getElementById("Finnish")?.parent()
        var nextSibling = sectionStart?.nextSibling()
        var checkSiblings = true
        var completeBlock = ""
        while nextSibling != nil, checkSiblings {
            if let element = nextSibling as? Element {
                // Stop parsing the section if the tag type matches the start of a new section
                checkSiblings = !["h2"].contains(element.tag().getName())
                completeBlock += "\(element)"
            }
            nextSibling = nextSibling?.nextSibling()
        }
        completeLanguage = completeBlock
    }

    private func parseEtymology(_ doc: Document, _ sectionId: String) throws {
        let sectionStart = try doc.getElementById(sectionId)?.parent()
        var nextSibling = sectionStart?.nextSibling()
        var checkSiblings = true
        var etymologyText = ""
        while nextSibling != nil, checkSiblings {
            if let element = nextSibling as? Element {
                // Stop parsing the section if the tag type matches the start of a new section
                checkSiblings = !["h3", "h4", "div", "h5"].contains(element.tag().getName())
                if element.tag().getName() == "p" {
                    etymologyText += try element.text()
                }
            }
            nextSibling = nextSibling?.nextSibling()
        }
        result[.etymology] = etymologyText
    }

    private func parsePronunciation() {}

    private func parseDeclension() {}

    private func parseSynonyms() {}

    private func parseNoun(_ doc: Document, _ sectionId: String) throws {
        let sectionStart = try doc.getElementById(sectionId)?.parent()
        var nextSibling = sectionStart?.nextSibling()
        var checkSiblings = true
        var text = ""
        while nextSibling != nil, checkSiblings {
            if let element = nextSibling as? Element {
                let tagName = element.tag().getName()
                // Stop parsing the section if the tag type matches the start of a new section
                checkSiblings = !["h3", "h4", "div", "h5"].contains(tagName)
                print(try element.text())
                if tagName == "p" {
                    text += try element.text()
                } else if tagName == "ol" {
                    for child in element.children() {
                        text += try child.text()
                    }
                }
            }
            nextSibling = nextSibling?.nextSibling()
        }
        result[.noun] = text
    }

    // MARK: Public interface

    func fetchTranslation(term: Term) -> Future<String, Never> {
        let url = buildUrl(from: term)
        let request = URLRequest(url: url)
        let publisher = Future<String, Never> { promise in
            let task = URLSession.shared.dataTask(with: request) { [unowned self] (data, _, _) in
                if let unwrappedData = data,
                    let source = String(data: unwrappedData, encoding: .utf8) {
                    try? self.parseContent(source: source)
                    promise(.success(self.completeLanguage))
                }
            }
            task.resume()
        }
        return publisher
    }

}
