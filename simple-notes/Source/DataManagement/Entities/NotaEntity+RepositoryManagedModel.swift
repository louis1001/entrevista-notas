//
//  NotaEntity+RepositoryManagedModel.swift
//  simple-notes
//
//  Created by Luis Gonzalez on 22/1/23.
//

import Foundation
import CoreDataRepository

extension NotaEntity: RepositoryManagedModel {
    public func create(from nota: Nota) {
        update(from: nota)
    }
    
    public typealias Unmanaged = Nota
    public var asUnmanaged: Nota {
        Nota(
            id: id ?? UUID(),
            titulo: titulo ?? "",
            contenido: contenido ?? "",
            fecha: fecha ?? .now,
            ultimaEdicion: ultimaEdicion ?? .now,
            url: objectID.uriRepresentation()
        )
    }
    
    public func update(from unmanaged: Nota) {
        id = unmanaged.id
        titulo = unmanaged.titulo
        contenido = unmanaged.contenido
        fecha = unmanaged.fecha
        ultimaEdicion = unmanaged.ultimaEdicion
    }
}
