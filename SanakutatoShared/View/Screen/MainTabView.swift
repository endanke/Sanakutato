//
//  MainTabView.swift
//  SanakutatoMacos
//
//  Created by Daniel Eke on 2020. 09. 19..
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DictionaryView().tabItem({ Text("Dictionary") })
            WebView(viewModel: WebViewModel(content: .googleTranslate))
                .tabItem({ Text("Google Translate") })
            WebView(viewModel: WebViewModel(content: .wiktionary))
                .tabItem({ Text("Wiktionary") })
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
