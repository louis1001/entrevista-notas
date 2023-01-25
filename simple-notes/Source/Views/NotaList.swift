//
//  NotaList.swift
//  simple-notes
//
//  Created by Luis Gonzalez on 23/1/23.
//

import SwiftUI

struct NotaList: View {
    // Observed y no State porque MainView está a cargo del view model
    @ObservedObject var viewModel: NotasViewModel
    @Binding var selection: Nota?
    
    var body: some View {
        List(selection: $selection) {
            ForEach(viewModel.notas.enumeratedList, id: \.element.id) { (i, nota) in
                NavigationLink(value: nota) {
                    NotaListItem(nota: nota, onDelete: { delete(indice: i) })
                }
            }
            .onDelete { indexSet in
                Task { await viewModel.deleteNota(indexSet)}
            }
        }
        .toolbar {
            toolbarItems
        }
    }
    
    private func delete(indice: Int) {
        Task {
            let indexSet = IndexSet(integer: indice)
            await viewModel.deleteNota(indexSet)
        }
    }
}

extension NotaList { // Toolbar
    var toolbarItems: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            SortingPicker(currentSorting: $viewModel.sorting)
            
            addNota
        }
    }
    
    var addNota: some View {
        Image(systemName: "square.and.pencil")
            .asButton {
                Task {
                    guard let nota = await viewModel.newNota() else {
                        return
                    }
                    
                    // Bug fix. Si pongo la selección ahora, List no sabe qué elegir
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        selection = nota
//                    }
                }
            }
            .keyboardShortcut("n", modifiers: .command)
    }
}

struct NotaListItem: View {
    var nota: Nota
    var onDelete: ()->Void
    
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
#if os(macOS)
        .contextMenu {
            Label("Delete", systemImage: "trash")
                .asButton {
                    onDelete()
                }
        }
#endif
    }
}
