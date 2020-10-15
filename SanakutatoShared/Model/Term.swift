//
//  Term.swift
//  SanakutatoShared
//
//  Created by Daniel Eke on 2020. 08. 29..
//

import Foundation
import CoreData

enum Language: String {
    case finnish
    case english
}

struct Term: Hashable {
    let language: Language
    let text: String

    @discardableResult func persist(in search: PersistentSearch) -> PersistentTerm {
        let fetchRequest = NSFetchRequest<PersistentTerm>(entityName: "PersistentTerm")
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "language == %@", language.rawValue),
            NSPredicate(format: "text == %@", text)
        ])
        if let persistent = try? Services.dataManager.persistentContainer.viewContext.fetch(fetchRequest).first {
            return persistent
        }
        let term = PersistentTerm(context: Services.dataManager.persistentContainer.viewContext)
        term.language = language.rawValue
        term.text = text
        term.search = search
        Services.dataManager.saveContext()
        return term
    }
}

extension PersistentTerm {
    func toIntermittent() -> Term? {
        guard let language = Language(rawValue: self.language ?? ""),
            let text = self.text else {
            return nil
        }
        return Term(language: language, text: text)
    }
}

struct Search: Hashable {
    var terms: [Term]
    var persistent: PersistentSearch?

    mutating func restore() -> PersistentSearch? {
        let fetchRequest = NSFetchRequest<PersistentSearch>(entityName: "PersistentSearch")
        do {
            let persistent = try Services.dataManager.persistentContainer.viewContext.fetch(fetchRequest).first
            self.terms = persistent?.terms?.map({ (obj) -> Term? in
                (obj as? PersistentTerm)?.toIntermittent()
            }).compactMap({ $0 }) ?? []
            return persistent
        } catch let error as NSError {
            fatalError("Could not restore: \(error), \(error.userInfo)")
        }
    }

    mutating func persist() {
        if persistent == nil {
            persistent = restore()
        }
        if persistent == nil {
            persistent = PersistentSearch(context: Services.dataManager.persistentContainer.viewContext)
        }
        guard let search = persistent else { return }
        search.terms?.addingObjects(from: self.terms.map({ $0.persist(in: search) }))
        Services.dataManager.saveContext()
    }
}
