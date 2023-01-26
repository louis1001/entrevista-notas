//
//  NotasViewModel.swift
//  simple-notes
//
//  Created by Luis Gonzalez on 22/1/23.
//

import SwiftUI
import Combine
import CoreData
import CoreDataRepository

@MainActor
class NotasViewModel: ObservableObject {
    // MARK: Published Variables
    @Published var notas: [Nota] = []
    @Published var searchQuery = "" {
        didSet {
            Task { await self.delayedSearch.attempt(searchQuery) }
        }
    }
    
    private var filter: NotaRequest {
        searchQuery.isEmpty ? .all : .search(searchQuery)
    }
    
    @AppStorage("notasOrderBy") var sorting = NotasSorting.byEditDate {
        didSet {
            Task { await self.refreshNotas(with: filter) }
        }
    }
    
    // MARK: Private Properties
    private let delayedSearch = DelayedSave<String>()
    private let delayedNotaSaving = DelayedSave<Nota>()
    
    private let backgroundQueue = DispatchQueue(label: "background-data-queue", qos: .userInitiated)
    private let repository: CoreDataRepository
    
    // MARK: Setup
    init(persistence: PersistenceController? = nil) {
        let persistence = persistence ?? PersistenceController()
        let context = backgroundQueue.sync {
            let context = persistence.container.newBackgroundContext()
            
            context.automaticallyMergesChangesFromParent = true
            return context
        }
        
        repository = CoreDataRepository(context: context)
        
        delayedSearch.saveAction = {[weak self] term in
            await self?.commitSearch(term)
        }
        
        delayedNotaSaving.saveAction = {[weak self] nota in
            await self?.commitSave(nota)
        }
        
        Task { await self.refreshNotas(with: .all) }
    }
}

// MARK: - CRUD
extension NotasViewModel {
    // Create
    @discardableResult
    func newNota() async -> Nota? {
        if let index = notas.firstIndex(where: { !$0.isUnedited }) {
            // Si hay una nota que es nueva y no ha sido editada
            
            // Si se está buscando, cancelar la busqueda
            searchQuery = ""
            
            // Retornar la nota que ya existe
            return notas[index]
        }
        
        let nota = Nota(id: UUID(), title: "", body: "")
        
        let result = await repository.create(nota)
        
        // Evitar llamar refresh y consultar core data de nuevo.
        // actualizar los datos actuales con la respuesta de .create
        switch result {
        case .success(let nota):
            // Esto puede causar problemas al tener un metodo de ordenación aparte de fecha reciente.
            // La nota se pondrá de primera, pero al editar cualquier cosa se va actualizar el orden
            notas.insert(nota, at: 0)
            return nota
        case .failure(let error):
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    // Read
    func refreshNotas(with filter: NotaRequest) async {
        let request = filter.fetchRequest(with: sorting)
        
        let result: Result<[Nota], _> = await repository.fetch(request)
        
        switch result {
        case .success(let notas): self.notas = notas
        case .failure(let error): print("Error fetching notas:\n\(error.localizedDescription)")
        }
    }
    
    // Update
    func updateNota(_ nota: Nota, force: Bool = false) async {
        await delayedNotaSaving.attempt(nota, force: force)
    }
    
    // Delete
    func deleteNota(_ indices: IndexSet) async {
        let urls = indices
            .compactMap { notas[$0].url }
        
        let result = await repository.delete(urls: urls)
        
        // En lugar de llamar refresh, utilizar el resultado de .delete
        // para actualizar el estado actual
        if result.failed.isEmpty {
            notas.remove(atOffsets: indices)
        } else {
            for url in result.success {
                // Solo remover las que ya no están en core data
                notas.removeAll { $0.url == url }
            }
        }
    }
}

// MARK: - Delayed Actions
extension NotasViewModel {
    // Para evitar muchas actualizaciones frecuentes,
    // se llama a estas funciones con un buffer
    
    private func commitSearch(_ term: String) async {
        let filter: NotaRequest = term.isEmpty ? .all : .search(term)
        
        await self.refreshNotas(with: filter)
    }
    
    private func commitSave(_ nota: Nota) async {
        var nota = nota
        nota.editDate = .now
        
        let result = await repository.update([nota])
        
        if result.failed.isEmpty {
            await refreshNotas(with: filter)
        } else {
            NSLog("Error updating the nota %@", nota.id.uuidString)
        }
    }
}
