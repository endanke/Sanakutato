//
//  Term.swift
//  SanakutatoShared
//
//  Created by Daniel Eke on 2020. 08. 29..
//

import Foundation

enum Language: String {
    case finnish
    case english
}

struct Term: Hashable {
    let language: Language
    let text: String
}
