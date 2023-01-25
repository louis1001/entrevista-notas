//
//  SortingPicker.swift
//  simple-notes
//
//  Created by Luis Gonzalez on 23/1/23.
//

import SwiftUI

struct SortingPicker: View {
    @Binding var currentSorting: NotasSorting
    
    @ViewBuilder
    func row(for sort: NotasSorting.Option) -> some View {
        let text = sort.rawValue.capitalized
        let arrowUpOrDown = currentSorting.ascending ? "arrow.up" : "arrow.down"
        let isSelected = currentSorting.option == sort
        
        Button {
            pressed(sorting: sort)
        } label: {
            if isSelected {
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
                .scaleEffect(0.8) // El botón se ve demasiado grande
        }
        .menuStyle(.button)
    }
    
    func pressed(sorting: NotasSorting.Option) {
        if currentSorting.option == sorting {
            currentSorting.toggle()
        } else {
            currentSorting = NotasSorting(
                option: sorting,
                ascending: sorting.isAscendingByDefault
            )
        }
    }
}
