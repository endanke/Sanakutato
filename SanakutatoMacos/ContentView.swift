//
//  ContentView.swift
//  SanakutatoMacos
//
//  Created by Daniel Eke on 2020. 08. 24..
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var model = ViewModel()
    @State var searchText: String = ""

    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            WebView(viewModel: model)

            VStack(alignment: .leading, spacing: 20) {
                TextField("Search text", text: $searchText, onCommit: {
                    self.model.searchText = self.searchText
                }).textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Text(model.url)

                List {
                    Section(header: Text("Search history")) {
                        ForEach(model.history, id: \.self) { text in
                            Text(text)
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
