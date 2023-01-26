//
//  NotasSorting.swift
//  simple-notes
//
//  Created by Luis Gonzalez on 22/1/23.
//

import Foundation

struct NotasSorting: Codable {
    enum Option: String, CaseIterable {
        case editDate
        case title
        case content
        
        var isAscendingByDefault: Bool {
            // Fechas por defecto la mas reciente primero
            if self == .editDate { return false }
            
            // Los campos de texto por defecto ascendentes/alfabéticos
            return true
        }
    }
    
    var option: Option
    var ascending: Bool
    
    mutating func toggle() {
        ascending.toggle()
    }
    
    static let byEditDate = NotasSorting(option: .editDate, ascending: false)
    static let byTitle = NotasSorting(option: .title, ascending: false)
    static let byContent = NotasSorting(option: .content, ascending: false)
}

extension NotasSorting: RawRepresentable {
    public init?(rawValue: String) {
        let values = rawValue.split(separator: " ")
        guard values.count == 2 else { return nil }
        
        let option = Option(rawValue: String(values[0])) ?? .editDate
        let ascending = values[1] == "true"
        self = NotasSorting(option: option, ascending: ascending)
    }
    
    public var rawValue: String {
        return "\(option.rawValue) \(ascending)"
    }
}
