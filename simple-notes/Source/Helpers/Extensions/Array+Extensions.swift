//
//  Array+Extensions.swift
//  simple-notes
//
//  Created by Luis Gonzalez on 23/1/23.
//

import Foundation

extension Sequence {
            // Hacer esta conversión dentro de `enumeratedList` causa un error.
    var asArray: [Element] { return Array(self) }
}

extension Array {
    var enumeratedList: [(offset: Int, element: Element)] {
        Swift.zip(self.indices, self).asArray
    }
}
