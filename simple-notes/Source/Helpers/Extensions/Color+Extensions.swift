//
//  Color+Extensions.swift
//  simple-notes
//
//  Created by Luis Gonzalez on 24/1/23.
//

import SwiftUI

extension Color {
    static var currentBackground: Color {
        #if os(macOS)
        Color(NSColor.windowBackgroundColor)
        #else
        Color(UIColor.systemBackground)
        #endif
    }
}
