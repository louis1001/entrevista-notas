//
//  NotaModel.swift
//  simple-notes
//
//  Created by Luis Gonzalez on 22/1/23.
//

import Foundation

public struct Nota: Hashable {
    let id: UUID
    var title: String
    var body: String
    var creationDate: Date = .now
    var editDate: Date = .now
    var url: URL?
}

extension Nota {
    var isUnedited: Bool {
        editDate == creationDate
    }
}
