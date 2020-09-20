//
//  SearchHistory.swift
//  SanakutatoShared
//
//  Created by Daniel Eke on 2020. 09. 19..
//

import Foundation

class SearchHistory: ObservableObject {
    @Published private(set) var searchText: String = ""
    @Published private(set) var history: [String] = []
    private var searchValues: Set<String> = []

    func setCurrent(searchText: String) {
        self.searchText = searchText
        if !searchValues.contains(searchText) {
            searchValues.insert(searchText)
            history.insert(searchText, at: 0)
        }
    }
}
