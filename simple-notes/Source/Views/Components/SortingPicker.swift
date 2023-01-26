//
//  SortingPicker.swift
//  simple-notes
//
//  Created by Luis Gonzalez on 23/1/23.
//

import SwiftUI

private extension NotasSorting.Option {
    var localizationKey: LocalizedStringKey {
        switch self {
        case .editDate: return "sort-edit-date"
        case .title: return    "sort-title"
        case .content: return  "sort-content"
        }
    }
}

struct SortingPicker: View {
    @Binding var currentSorting: NotasSorting
    
    @ViewBuilder
    func row(for sort: NotasSorting.Option) -> some View {
        let arrowUpOrDown = currentSorting.ascending ? "arrow.up" : "arrow.down"
        let isSelected = currentSorting.option == sort
        
        Button {
            pressed(sorting: sort)
        } label: {
            if isSelected {
                Label(sort.localizationKey, systemImage: arrowUpOrDown)
                    .labelStyle(.titleAndIcon)
            } else {
                Text(sort.localizationKey)
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
