//
//  NotaEditor.swift
//  simple-notes
//
//  Created by Luis Gonzalez on 23/1/23.
//

import SwiftUI

struct NotaEditor: View {
    @State var nota: Nota
    var saveAction: (Nota)->Void
    
    var body: some View {
        VStack {
            TextField("Nueva Nota", text: $nota.titulo)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            
            TextEditor(text: $nota.contenido)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        }
        .padding()
        .onChange(of: nota, perform: saveAction)
    }
}
