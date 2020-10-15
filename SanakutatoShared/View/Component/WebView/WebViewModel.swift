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
    @Published var searchTerm: Term = Term(language: .english, text: "") {
        didSet {
            switch content {
            case .googleTranslate:
                url = Services.googleTranslate.buildURL(from: searchTerm.text)
            case .wiktionary:
                url = "https://en.wiktionary.org/wiki/\(searchTerm.text)"
            case .wiktionaryExtract:
                fetchWiktionaryContent()
            }
        }
    }
    @Published var url: String = ""
    @Published var htmlResource: String?

    let content: WebContent
    let monitoredResourceURL: String?
    var webViewNavigationPublisher = PassthroughSubject<WebViewNavigation, Never>()
    var showLoader = PassthroughSubject<Bool, Never>()
    var valuePublisher = PassthroughSubject<String, Never>()
    var cancellables = Set<AnyCancellable>()

    init(content: WebContent) {
        self.content = content
        self.monitoredResourceURL = (content == .googleTranslate) ? "https://translate.google" : nil
        Services.searchHistory.$searchTerm
            .dropFirst()
            .sink(receiveValue: { (value) in
                self.searchTerm = value
            })
            .store(in: &cancellables)
    }

    func resourceLoaded(content: String) {
        Services.googleTranslate.parseContent(input: content)
    }

    private func fetchWiktionaryContent() {
        let words = searchTerm.text.components(separatedBy: " ")
        Services.wiktionary.fetchTranslation(term: Term(language: .finnish, text: words[0]))
            .receive(on: RunLoop.main)
            .sink(receiveValue: { (translation) in
                self.htmlResource = translation
            })
            .store(in: &cancellables)
    }

}
