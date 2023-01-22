//
//  PersistenceController+Extension.swift
//  simple-notes
//
//  Created by Luis Gonzalez on 21/1/23.
//

import Foundation
import LoremSwiftum

extension PersistenceController {
    static var preview: PersistenceController {
        let controller = PersistenceController(inMemory: true)
        
        for _ in 0..<10 {
            let nota = NotaEntity(context: controller.container.viewContext)
            nota.id = UUID()
            nota.ultimaEdicion = .now
            nota.fecha = .now
            nota.titulo = Lorem.words(3)
            nota.contenido = Lorem.paragraphs(Int.random(in: 0..<4))
        }
        
        return controller
    }
}
