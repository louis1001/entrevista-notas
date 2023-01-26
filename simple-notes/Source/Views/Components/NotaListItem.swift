//
//  NotaListItem.swift
//  simple-notes
//
//  Created by Luis Gonzalez on 24/1/23.
//

import SwiftUI

struct NotaListItem: View {
    var nota: Nota
    
    private static let contentFontSize: CGFloat = IS_MAC ? 10 : 14
    
    private var title: some View {
        Group {
            if nota.title.isEmpty {
                Text("new-note")
            } else {
                Text(nota.title)
            }
        }
        .font(.body)
        .bold()
    }
    
    private var content: some View {
        Group {
            if nota.body.isEmpty {
                Text("no-content") + Text("\n\n")
            } else {
                Text(nota.body + "\n\n") // Saltos de linea para que siempre tenga el tamaño máximo
            }
        }
        .lineLimit(2)
        .font(.custom(CONTENT_FONT_NAME, size: Self.contentFontSize))
        .opacity(0.8)
        .fixedSize(horizontal: false, vertical: true)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            title
            
            content
            
            Text(nota.editDate.formatted())
                .font(.system(size: 10))
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
        }
        .frame(height: IS_MAC ? 70 : 80, alignment: .topLeading)
    }
}
