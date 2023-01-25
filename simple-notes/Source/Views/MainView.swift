//
//  MainView.swift
//  simple-notes
//
//  Created by Luis Gonzalez on 23/1/23.
//

import SwiftUI

struct MainView: View {
    @State var selection: Nota? = nil
    @StateObject var viewModel = NotasViewModel()
    
    @State private var pickingSort = false
    
    var body: some View {
        NavigationSplitView(sidebar: {sidebar}, detail: {detail})
        .searchable(text: $viewModel.searchQuery)
    }
    
    var sidebar: some View {
        NotaList(viewModel: viewModel, selection: $selection)
    }
    
    @ViewBuilder
    var detail: some View {
        if let selection {
            NotaEditor(nota: selection) { nota in
                Task { await viewModel.updateNota(nota) }
            }
                .id(selection.id)
        }
    }
}
