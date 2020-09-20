//
//  DictionarySource.swift
//  SanakutatoShared
//
//  Created by Daniel Eke on 2020. 08. 29..
//

import Foundation
import Combine

class DictionarySource: ObservableObject {

    @Published var translatedTerms: [Term] = []
    @Published var translatedSentence: String = ""
    
}
