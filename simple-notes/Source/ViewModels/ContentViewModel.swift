//
//  ContentViewModel.swift
//  simple-notes
//
//  Created by Luis Gonzalez on 22/1/23.
//

import Combine
import CoreData
import CoreDataRepository
import PredicateKit

extension ContentView {
    class ViewModel: ObservableObject {
        @Published var notas: [Nota] = []
        @Published var searchQuery = "" {
            didSet {
                delayedSearch.attempt(searchQuery)
            }
        }
        
        private let delayedSearch = DelayedSave<String>()
        private let delayedNotaSaving = DelayedSave<Nota>()
        
        private var repository: CoreDataRepository?
        private var cancellable: AnyCancellable?
        
        private var query: NotaRequest = .all
        
        init() {
            delayedSearch.saveAction = {[weak self] term in
                let query: NotaRequest = term.isEmpty ? .all : .search(term)
                self?.setQuery(query)
            }
            
            delayedNotaSaving.saveAction = {[weak self] nota in
                var nota = nota
                nota.ultimaEdicion = .now
                // Si falla no tengo mucho que hacer.
                let _ = await self?.repository?.update([nota])
            }
        }
        
        func newNota() {
            let isFirst = notas.isEmpty
            Task {[repository] in
                let nota = Nota(id: UUID(), titulo: "", contenido: "")
                
                let _ = await repository?.create(nota)
                
                if isFirst {
                    // A bug on iPad when there's no notes added. Refresh data
                    setQuery(searchQuery.isEmpty ? .all : .search(searchQuery))
                }
            }
        }
        
        func deleteNota(_ indices: IndexSet) {
            let urls = indices
                .compactMap { notas[$0].url }
            
            notas.remove(atOffsets: indices)
            
            Task {[repository] in
                await repository?.delete(urls: urls)
            }
        }
        
        func updateNota(_ nota: Nota) {
            delayedNotaSaving.attempt(nota)
        }
        
        private func setQuery(_ query: NotaRequest) {
            guard let repository else {
                fatalError("Trying to set the fetch query")
            }
            
            self.query = query
            
            cancellable?.cancel() // Cancel the previous subscription
            
            let request = query.fetchRequest
            let result: AnyPublisher<[Nota], CoreDataRepositoryError> = repository
                .fetchSubscription(request)
            
            cancellable = result.subscribe(on: DispatchQueue.main)
                .receive(on: RunLoop.main)
                .sink { completion in
                    switch completion {
                    case .finished:
                        // log
                        break
                    default:
                        fatalError("Failed fetch of data")
                    }
                } receiveValue: {[weak self] value in
                    // store in published notas
                    self?.notas = value
                    print(value.map(\.titulo))
                }
        }
        
        func setContext(_ context: NSManagedObjectContext) {
            repository = CoreDataRepository(context: context)
            
            setQuery(.all)
        }
    }
}

extension ContentView.ViewModel {
    enum NotaRequest {
        case all
        case search(String)
        
        var fetchRequest: NSFetchRequest<NotaEntity> {
            let fetchRequest = NotaEntity.fetchRequest() as! NSFetchRequest<NotaEntity>
            
            switch self {
            case .all:
                break // No conditions
            case .search(let query):
                let predicate = NSPredicate(format: "(titulo CONTAINS[cd] %@) OR (contenido CONTAINS[cd] %@)", query, query)
                fetchRequest.predicate = predicate
            }
            
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(keyPath: \NotaEntity.ultimaEdicion, ascending: false)
            ]
            
            return fetchRequest
        }
    }
}
