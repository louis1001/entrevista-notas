//
//  simple_notesApp.swift
//  simple-notes
//
//  Created by Luis Gonzalez on 21/1/23.
//

import SwiftUI

@main
struct simple_notesApp: App {
    let persistenceController = PersistenceController.shared
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .onChange(of: scenePhase) {_ in
            // Save when going to or coming from background
            persistenceController.save()
        }
    }
}
