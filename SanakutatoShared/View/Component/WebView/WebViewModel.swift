//
//  WebViewModel.swift
//  SanakutatoShared
//
//  Created by Daniel Eke on 2020. 09. 09..
//

import Foundation
import WebKit
import Combine

enum WebViewNavigation {
    case backward, forward
}

enum WebUrl {
    case localUrl, publicUrl
}

enum WebContent {
    case googleTranslate
    case wiktionary
    case wiktionaryExtract
}

class WebViewModel: ObservableObject {
    @Published var searchText: String = "" {
        didSet {
            switch content {
            case .googleTranslate:
                url = "https://translate.google.com/#view=home&op=translate&sl=fi&tl=en&text=\(searchText)"
            case .wiktionary:
                url = "https://en.wiktionary.org/wiki/\(searchText)"
            case .wiktionaryExtract:
                fetchWiktionaryContent()
            }
        }
    }
    @Published var url: String = ""
    @Published var htmlResource: String?

    let content: WebContent
    let monitoredResourceURL: String?
    var searchTerm: Term { return Term(language: .english, text: searchText) }
    var webViewNavigationPublisher = PassthroughSubject<WebViewNavigation, Never>()
    var showLoader = PassthroughSubject<Bool, Never>()
    var valuePublisher = PassthroughSubject<String, Never>()
    var cancellables = Set<AnyCancellable>()

    init(content: WebContent) {
        self.content = content
        self.monitoredResourceURL = (content == .googleTranslate) ? "https://translate.google" : nil
        Services.searchHistory.$searchText
            .dropFirst()
            .sink(receiveValue: { (value) in
                self.searchText = value
            })
            .store(in: &cancellables)
    }

    func resourceLoaded(content: String) {
        Services.googleTranslate.parseTerms(input: content)
    }

    private func fetchWiktionaryContent() {
        Services.wiktionary.fetchTranslation(term: Term(language: .finnish, text: searchText))
            .receive(on: RunLoop.main)
            .sink(receiveValue: { (translation) in
                print(translation)
                self.htmlResource = translation
            })
            .store(in: &cancellables)
    }

}
