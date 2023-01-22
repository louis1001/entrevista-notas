//
//  ContentView.swift
//  simple-notes
//
//  Created by Luis Gonzalez on 21/1/23.
//

import SwiftUI

struct NotaListItem: View {
    @ObservedObject var nota: NotaEntity
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(nota.titulo ?? "Nueva nota")
                .font(.title2)
                .bold()
            
            Text((nota.contenido ?? "sin contenido") + "\n\n")
                .font(.system(size: 10))
                .lineLimit(2)
                .opacity(0.7)
            
            Text((nota.ultimaEdicion ?? .now).formatted())
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                .font(.footnote)
        }
    }
}

struct ContentView: View {
    @State var selection: NotaEntity? = nil
    @FetchRequest(sortDescriptors: [SortDescriptor(\.ultimaEdicion)]) var notas: FetchedResults<NotaEntity>
    
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                ForEach(notas, id: \.id) { nota in
                    NavigationLink(value: nota) {
                        NotaListItem(nota: nota)
                    }
                }
            }
        } detail: {
            if let selection {
                VStack {
                    Text(selection.titulo ?? "")
                        .font(.title2)
                        .bold()
                    ScrollView {
                        Text(selection.contenido ?? "")
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                    }
                }
                .padding()
            }
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
