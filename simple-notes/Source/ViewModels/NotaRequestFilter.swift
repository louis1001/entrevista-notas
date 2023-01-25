//
//  NotaRequestFilter.swift
//  simple-notes
//
//  Created by Luis Gonzalez on 24/1/23.
//

import CoreData

extension NotasViewModel {
    enum NotaRequest {
        case all
        case search(String)
        
        func fetchRequest(with sorting: NotasSorting) -> NSFetchRequest<NotaEntity> {
            let fetchRequest = NotaEntity.fetchRequest() as! NSFetchRequest<NotaEntity>
            
            switch self {
            case .all:
                break // No conditions
            case .search(let query):
                let predicate = NSPredicate(format: "(titulo CONTAINS[cd] %@) OR (contenido CONTAINS[cd] %@)", query, query)
                fetchRequest.predicate = predicate
            }
            
            let sortDescriptors: [NSSortDescriptor]
            
            switch sorting.option {
            case .titulo:
                sortDescriptors = [
                    NSSortDescriptor(keyPath: \NotaEntity.titulo, ascending: sorting.ascending)
                ]
            case .contenido:
                sortDescriptors = [
                    NSSortDescriptor(keyPath: \NotaEntity.contenido, ascending: sorting.ascending)
                ]
            case .fecha:
                sortDescriptors = [
                    NSSortDescriptor(keyPath: \NotaEntity.ultimaEdicion, ascending: sorting.ascending)
                ]
            }
            
            fetchRequest.sortDescriptors = sortDescriptors
            
            return fetchRequest
        }
    }
}
