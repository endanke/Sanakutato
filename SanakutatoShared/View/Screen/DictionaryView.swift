//
//  DictionaryView.swift
//  SanakutatoMacos
//
//  Created by Daniel Eke on 2020. 09. 19..
//

import SwiftUI

struct DictionaryView: View {
    @ObservedObject var webViewModel = WebViewModel(content: .wiktionaryExtract)
    @ObservedObject var searchHistory = Services.searchHistory
    @ObservedObject var googleTranslate = Services.googleTranslate
    @State var searchText: String = ""

    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            VStack(alignment: .leading, spacing: 20) {
                WebView(viewModel: webViewModel)
            }

            VStack(alignment: .leading, spacing: 20) {
                TextField("Search text", text: $searchText, onCommit: {
                    self.searchHistory.searchText = self.searchText
                    self.searchHistory.history.append(self.searchText)
                }).textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Text(webViewModel.url)
                Text(searchHistory.searchText)

                List {
                    Section(header: Text("Search history")) {
                        ForEach(searchHistory.history, id: \.self) { text in
                            Text(text)
                        }
                    }
                }

                List {
                    Section(header: Text("Translation")) {
                        ForEach(googleTranslate.translatedTerms, id: \.self) { term in
                            Text(term.text)
                        }
                    }
                }
            }
        }
    }
}

struct DictionaryView_Previews: PreviewProvider {
    static var previews: some View {
        DictionaryView()
    }
}
