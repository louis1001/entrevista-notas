//
//  NotaListItem.swift
//  simple-notes
//
//  Created by Luis Gonzalez on 24/1/23.
//

import SwiftUI

struct NotaListItem: View {
    var nota: Nota
    
    private var titulo: String {
        nota.titulo.isEmpty
        ? "Nueva nota"
        : nota.titulo
    }
    
    private var contenido: String {
        nota.contenido.isEmpty
        ? "Sin contenido"
        : nota.contenido
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(titulo)
                .font(.title2)
                .bold()
            
            // + "\n\n" Para que el Text siempre tenga la algura máxima de 2 lineas
            Text(contenido + "\n\n")
                .font(.system(size: 10))
                .lineLimit(2)
                .opacity(0.7)
            
            Text(nota.ultimaEdicion.formatted())
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                .font(.footnote)
        }
    }
}
