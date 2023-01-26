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
            title: titulo ?? "",
            body: contenido ?? "",
            creationDate: fecha ?? .now,
            editDate: ultimaEdicion ?? .now,
            url: objectID.uriRepresentation()
        )
    }
    
    public func update(from unmanaged: Nota) {
        id = unmanaged.id
        titulo = unmanaged.title
        contenido = unmanaged.body
        fecha = unmanaged.creationDate
        ultimaEdicion = unmanaged.editDate
    }
}
