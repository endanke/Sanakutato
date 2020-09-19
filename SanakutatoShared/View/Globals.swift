//
//  Globals.swift
//  SanakutatoShared
//
//  Created by Daniel Eke on 2020. 08. 29..
//

import SwiftUI

#if os(macOS)
typealias Representable = NSViewRepresentable
typealias RepresentableContext = NSViewRepresentableContext
#else
typealias Representable = UIViewRepresentable
typealias RepresentableContext = UIViewRepresentableContext
#endif
