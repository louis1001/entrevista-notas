//
//  NotaModel.swift
//  simple-notes
//
//  Created by Luis Gonzalez on 22/1/23.
//

import Foundation

public struct Nota: Hashable {
    let id: UUID
    var titulo: String
    var contenido: String
    var fecha: Date = .now
    var ultimaEdicion: Date = .now
    var url: URL?
}

extension Nota {
    var noHaSidoEditada: Bool {
        ultimaEdicion == fecha
    }
}
