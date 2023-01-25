//
//  View+Extensions.swift
//  simple-notes
//
//  Created by Luis Gonzalez on 23/1/23.
//

import SwiftUI

extension View {
    func asButton(_ action: @escaping()-> Void) -> some View {
        /// Helper para convertir vista en un botón.
        Button(action: action, label: {self})
    }
    
    /// Aplica modificadores condicionalmente
    @ViewBuilder
    func `if`(_ condition: Bool, then: (Self) -> some View, else otherwise: ((Self) -> some View)? = nil) -> some View {
        if condition {
            then(self)
        } else if let otherwise {
            otherwise(self)
        } else {
            self
        }
    }
}
