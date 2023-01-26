//
//  PersistenceController.swift
//  simple-notes
//
//  Created by Luis Gonzalez on 21/1/23.
//

import CoreData
import Foundation

class PersistenceController: ObservableObject {
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Main")
        if inMemory {
            let psd = NSPersistentStoreDescription()
            psd.type = NSInMemoryStoreType
            
            container.persistentStoreDescriptions = [psd]
        }
        
        container.loadPersistentStores { description, error in
            if let error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
}
