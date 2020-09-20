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
    @State var selection: Int = 0

    var body: some View {
        HStack(alignment: .center, spacing: .pdNormal) {
            VStack(alignment: .leading, spacing: .pdNormal) {
                WebView(viewModel: webViewModel)
            }

            VStack(alignment: .leading, spacing: .pdNormal) {
                TextField("Search text", text: $searchText, onCommit: {
                    self.searchHistory.searchText = self.searchText
                    self.searchHistory.history.append(self.searchText)
                }).textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Picker(selection: $selection,
                       label: Text("Source:"),
                       content: {
                        Text("English").tag(0)
                        Text("Finnish").tag(1)
                })

                Text(webViewModel.url)
                Text(searchHistory.searchText)

                List {
                    Section(header: Text("Translation")) {
                        Text(googleTranslate.translatedSentence)
                        ForEach(googleTranslate.translatedTerms, id: \.self) { term in
                            Text(term.text)
                        }
                    }
                }

                List {
                    Section(header: Text("Search history")) {
                        ForEach(searchHistory.history, id: \.self) { text in
                            Text(text)
                        }
                    }
                }
            }.padding(.pdSmall)
        }
    }
}

struct DictionaryView_Previews: PreviewProvider {
    static var previews: some View {
        DictionaryView()
    }
}
