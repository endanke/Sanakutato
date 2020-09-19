//
//  SearchHistory.swift
//  SanakutatoShared
//
//  Created by Daniel Eke on 2020. 09. 19..
//

import Foundation

class SearchHistory: ObservableObject {
    @Published var searchText: String = ""
    @Published var history: [String] = []
}
