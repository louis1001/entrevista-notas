//
//  NotaListItem.swift
//  simple-notes
//
//  Created by Luis Gonzalez on 24/1/23.
//

import SwiftUI

let CONTENT_FONT_NAME = "Noto Sans Armenian Regular"

struct NotaListItem: View {
    var nota: Nota
    
    private static let contentFontSize: CGFloat = IS_MAC ? 10 : 14
    
    private var title: String {
        nota.title.isEmpty
        ? "Nueva nota"
        : nota.title
    }
    
    private var content: String {
        nota.body.isEmpty
        ? "sin contenido"
        : nota.body
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.body)
                .bold()
            
            Text(content + "\n\n") // Saltos de linea para que siempre tenga el tamaño máximo
                .lineLimit(2)
                .font(.custom(CONTENT_FONT_NAME, size: Self.contentFontSize))
                .opacity(0.8)
                .fixedSize(horizontal: false, vertical: true)
            
            Text(nota.editDate.formatted())
                .font(.system(size: 10))
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
        }
        .frame(height: IS_MAC ? 70 : 80, alignment: .topLeading)
    }
}
