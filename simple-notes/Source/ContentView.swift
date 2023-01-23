//
//  ContentView.swift
//  simple-notes
//
//  Created by Luis Gonzalez on 21/1/23.
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
            Text(titulo + " ")
                .font(.title2)
                .bold()
            
            Text((contenido) + "\n\n")
                .font(.system(size: 10))
                .lineLimit(2)
                .opacity(0.7)
            
            Text((nota.ultimaEdicion).formatted())
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                .font(.footnote)
        }
    }
}

struct SortingPicker: View {
    @Binding var currentSorting: NotasSorting
    func row(for sort: NotasSorting.Option) -> some View {
        Button {
            if currentSorting.option == sort {
                currentSorting.toggle()
            } else {
                currentSorting = NotasSorting(
                    option: sort,
                    ascending: sort.isAscendingByDefault
                )
            }
        } label: {
            let text = sort.rawValue.capitalized
            if currentSorting.option == sort {
                let arrowUpOrDown = currentSorting.ascending ? "arrow.up" : "arrow.down"
                Label(text, systemImage: arrowUpOrDown)
                    .labelStyle(.titleAndIcon)
            } else {
                Text(text)
            }
        }
    }
    
    var body: some View {
        Menu {
            ForEach(NotasSorting.Option.allCases, id: \.rawValue) {sort in
                row(for: sort)
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
        }
        .menuStyle(.button)
    }
}

struct ContentView: View {
    @State var selection: Nota? = nil
    @StateObject var viewModel = NotasViewModel()
    @Environment(\.managedObjectContext) var moc
    
    @State private var pickingSort = false
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                ForEach(viewModel.notas, id: \.id) { nota in
                    NavigationLink(value: nota) {
                        NotaListItem(nota: nota)
                    }
                }
                .onDelete { indexSet in
                    Task { await viewModel.deleteNota(indexSet) }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    SortingPicker(currentSorting: $viewModel.sorting)
                    
                    Button {
                        Task { await viewModel.newNota() }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        } detail: {
            if let selection {
                NotaEditor(nota: selection, saveAction: { viewModel.updateNota($0) })
                    .id(selection.id)
            }
        }
        .searchable(text: $viewModel.searchQuery)
        .onAppear {
            viewModel.setContext(moc)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static let persistenceController = PersistenceController.preview
    
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
}
