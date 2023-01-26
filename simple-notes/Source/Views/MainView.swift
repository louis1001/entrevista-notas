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
    
    @State private var columnVisibility = NavigationSplitViewVisibility.automatic
    
    var body: some View {
        // MARK: Navigation Split View
        NavigationSplitView(columnVisibility: $columnVisibility, sidebar: {sidebar}, detail: {detail})
        .searchable(text: $viewModel.searchQuery)
        #if os(macOS)
        .frame(minWidth: 700, minHeight: 200)
        .navigationSplitViewStyle(.prominentDetail)
        .onAppear {
            columnVisibility = .all
        }
        #else
        .navigationSplitViewStyle(.automatic)
        #endif
    }
    
    // MARK: Side Bar
    var sidebar: some View {
        NotaList(viewModel: viewModel, selection: $selection)
#if os(macOS)
    .navigationSplitViewColumnWidth(min: 100, ideal: 200, max: 350)
#else
    .navigationSplitViewColumnWidth(min: 100, ideal: 400, max: 400)
#endif
    .navigationTitle("list-title")
    }
    
    // MARK: Detail
    @ViewBuilder
    var detail: some View {
        if let selection {
            NotaEditor(nota: selection) { nota in
                Task { await viewModel.updateNota(nota) }
            }
                .id(selection.id)
        } else {
            VStack {
                Text("detail-placeholder")
            }
                .id(-123)
        }
    }
}
