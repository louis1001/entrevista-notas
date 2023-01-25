//
//  NotaModel+UnmanagedModel.swift
//  simple-notes
//
//  Created by Luis Gonzalez on 22/1/23.
//

import Foundation
import CoreData
import CoreDataRepository

extension Nota: UnmanagedModel {
    public var managedRepoUrl: URL? {
        get {
            url
        }
        
        set {
            url = newValue
        }
    }
    
    public func asRepoManaged(in context: NSManagedObjectContext) -> NotaEntity {
        let object = NotaEntity(context: context)
        object.id = id
        object.titulo = titulo
        object.contenido = contenido
        object.fecha = fecha
        object.ultimaEdicion = ultimaEdicion
        
        return object
    }
}
