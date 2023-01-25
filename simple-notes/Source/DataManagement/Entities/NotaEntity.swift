//
//  NotaEntity.swift
//  simple-notes
//
//  Created by Luis Gonzalez on 22/1/23.
//

import CoreData

@objc(NotaEntity)
public final class NotaEntity: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var titulo: String?
    @NSManaged var contenido: String?
    @NSManaged var fecha: Date?
    @NSManaged var ultimaEdicion: Date?
}
