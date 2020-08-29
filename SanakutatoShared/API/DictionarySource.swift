//
//  DictionarySource.swift
//  SanakutatoShared
//
//  Created by Daniel Eke on 2020. 08. 29..
//

import Foundation

protocol DictionarySource {

    func fetchTranslation(term: Term)

}
