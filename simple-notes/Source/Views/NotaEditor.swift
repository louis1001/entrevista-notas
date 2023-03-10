//
//  NotaEditor.swift
//  simple-notes
//
//  Created by Luis Gonzalez on 23/1/23.
//

import SwiftUI

// MARK: General
struct NotaEditor: View {
    @State var nota: Nota
    var saveAction: (Nota)->Void
    
    #if os(macOS)
    private var wideScreen: Bool { true }
    #else
    @Environment(\.horizontalSizeClass) private var hsc
    private var wideScreen: Bool { hsc == .regular }
    #endif
    
    var body: some View {
        VStack(spacing: 0) {
            topSection
                .padding(.horizontal)
                .padding(.bottom, 5)
                .toolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
                        toolbarItems
                    }
                }
            
            if !wideScreen {
                Divider()
                    .padding(.top, 5)
                    .padding(.horizontal)
            }
            
            contentField
        }
        .background(Color.currentBackground, ignoresSafeAreaEdges: .all)
        .onChange(of: nota, perform: saveAction)
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
        .navigationTitle("")
    }
}

// MARK: Editor Header
private extension NotaEditor {
    var titleField: some View {
        TextField("new-note", text: $nota.title)
            .textFieldStyle(.plain)
            .font(.title2)
            .bold()
    }
    
    var timeStamp: some View {
        VStack(alignment: .trailing) {
            Text("created-at")
                .font(.caption)
            Text(nota.creationDate.formatted())
                .font(.caption2)
        }
        .opacity(0.7)
    }
    
    @ViewBuilder
    var topSection: some View {
        if wideScreen {
            HStack {
                titleField
                
                timeStamp
            }
        } else {
            // Siempre iPhone (no wide screen)
            titleField
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: Nota Content
private extension NotaEditor {
    var contentField: some View {
        ZStack {
            if nota.body.isEmpty {
                Text("write-your-note")
                    .opacity(0.4)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .allowsHitTesting(false)
            }
            
            CustomizableTextEditor(text: $nota.body, fontName: CONTENT_FONT_NAME, fontSize: 14)
                .textPadding(20)
                .maxWidth(900)
#if os(macOS)
                .onHover {inFrame in
                    if inFrame {
                        NSCursor.iBeam.set()
                    } else {
                        NSCursor.arrow.set()
                    }
                }
#endif
        }
    }
}

// MARK: Toolbar Items
private extension NotaEditor {
    var toolbarItems: some View {
        Group {
            if !wideScreen {
                timeStamp
            }
            shareAction
        }
    }
}

// MARK: Sharing
private extension NotaEditor {
    var notaAsText: String {
        "\(nota.title)\n\n\(nota.body)"
    }
    
    var shareAction: some View {
        ShareLink(items: [notaAsText]) {
            Image(systemName: "square.and.arrow.up")
        }
    }
}

// MARK: Focus State
private extension NotaEditor {
    enum FieldFocus {
        case title
        case content
    }
}
