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
    
    // MARK: macOS Header
    private var macHeader: some View {
        Text("list-title")
            .font(.title)
            .bold()
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
            .padding(.horizontal)
    }
    
    var body: some View {
        VStack {
#if os(macOS)
            macHeader
#endif
            
            listContent.toolbar { toolbarItems }
        }
        .overlay {
            if viewModel.notas.isEmpty {
                Text("create-note")
                    .opacity(0.8)
                    .blendMode(.multiply)
            }
        }
    }
    
    // MARK: Items list
    private var listContent: some View {
        List(selection: $selection) {
            ForEach(
                viewModel.notas.enumeratedList,
                id: \.element.id,
                content: notaRow
            )
            .onDelete { indexSet in
                Task { await viewModel.deleteNota(indexSet)}
            }
            
            if viewModel.notas.isEmpty {
                VStack{}
                    .frame(minWidth: 0, maxWidth: .infinity)
            }
        }
    }
    
    // MARK: Item row
    private func notaRow(indice: Int, nota: Nota) -> some View {
        NavigationLink(value: nota) {
            NotaListItem(nota: nota)
        }
#if os(macOS)
        .contextMenu {
            Label("delete-note", systemImage: "trash")
                .asButton { delete(indice: indice) }
        }
#endif
    }
}

// MARK: Toolbar elements
private extension NotaList {
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

// MARK: Functions
private extension NotaList {
    func delete(indice: Int) {
        Task {
            let indexSet = IndexSet(integer: indice)
            await viewModel.deleteNota(indexSet)
        }
    }
}
