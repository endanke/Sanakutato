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
                    self.search(for: self.searchText)
                }).textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Text("Words: ")
                ScrollView(.horizontal, showsIndicators: false) {
                     HStack {
                        ForEach(searchText.components(separatedBy: " "), id: \.self) { word in
                            Button("\(word)") { self.search(for: word) }
                        }
                     }
                }

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
                    Section(header: Text("Search history")) {
                        ForEach(searchHistory.history, id: \.self) { text in
                            Button("\(text)") { self.search(for: text) }
                        }
                    }
                }
            }.padding(.pdSmall)
        }
    }

    func search(for searchText: String) {
        self.searchText = searchText
        self.searchHistory.setCurrent(searchText: searchText)
    }
}

struct DictionaryView_Previews: PreviewProvider {
    static var previews: some View {
        DictionaryView()
    }
}
