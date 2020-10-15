//
//  SearchHistory.swift
//  SanakutatoShared
//
//  Created by Daniel Eke on 2020. 09. 19..
//

import Foundation

class SearchHistory: ObservableObject {
    @Published private(set) var searchTerm: Term = Term(language: .english, text: "")
    @Published private(set) var history: Search
    private var searchValues: Set<Term>

    init() {
        var history = Search(terms: [])
        _ = history.restore()
        self.history = history
        self.searchValues = Set(history.terms)
    }

    func search(term: Term) {
        self.searchTerm = term
        if !searchValues.contains(searchTerm) {
            searchValues.insert(searchTerm)
            history.terms.insert(searchTerm, at: 0)
        }
        history.persist()
    }
}
