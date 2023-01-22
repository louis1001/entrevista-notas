//
//  PersistenceController+Extension.swift
//  simple-notes
//
//  Created by Luis Gonzalez on 21/1/23.
//

import Foundation

extension PersistenceController {
    static var preview: PersistenceController {
        let controller = PersistenceController(inMemory: true)
        
        for i in 0..<10 {
            let nota = Nota(context: controller.container.viewContext)
            nota.id = UUID()
            nota.ultimaEdicion = .now
            nota.fecha = .now
            nota.titulo = "Nueva nota \(i)"
            nota.contenido = "El contenido de esta nota se repite. El contenido corto no debería tener mas de 2 lineas."
            nota.contenidoCorto = nota.contenido
        }
        
        return controller
    }
}
