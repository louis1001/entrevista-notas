//
//  simple_notesApp.swift
//  simple-notes
//
//  Created by Luis Gonzalez on 21/1/23.
//

import SwiftUI

@main
struct simple_notesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        #endif
    }
}
