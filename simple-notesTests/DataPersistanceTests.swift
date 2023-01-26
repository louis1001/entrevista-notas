//
//  DataPersistanceTests.swift
//  simple-notesTests
//
//  Created by Luis Gonzalez on 22/1/23.
//

import XCTest
import CoreData
import CoreDataRepository
@testable import simple_notes

final class DataPersistanceTests: XCTestCase {
    private let persistenceController: PersistenceController = PersistenceController(inMemory: true)
    private var viewModel: NotasViewModel?
    
    // MARK: Setup
    @MainActor override func setUpWithError() throws {
        viewModel = NotasViewModel(persistence: persistenceController)
        
        try super.setUpWithError()
    }
    
    override func tearDown() {
        viewModel = nil
    }
    
    // MARK: Tests
    @MainActor func testEmptyNotas() throws {
        let viewModel = try XCTUnwrap(viewModel)
        
        XCTAssert(viewModel.notas.isEmpty, "El contexto no debería mantener ninguna nota al empezar") // Vacías al empezar
    }
    
    @discardableResult
    func createNota() async throws -> Nota {
        let nota = await viewModel?.newNota()
        return try XCTUnwrap(nota)
    }
    
    func testNewNota() async throws {
        let nota = try await createNota()
        
        XCTAssertEqual(nota.title, "")
    }
    
    @MainActor func testEditNota() async throws {
        let viewModel = try XCTUnwrap(viewModel)
        var nota: Nota = try await createNota()
        
        //RunLoop.main.run(mode: .default, before: .distantPast)
        
        nota.title = "Una nota editada"
        nota.body = "Con un contenido simple."
        
        await viewModel.updateNota(nota, force: true)
        
        XCTAssertEqual(viewModel.notas.first?.title, nota.title)
        XCTAssertEqual(viewModel.notas.first?.body, nota.body)
    }
    
    @MainActor
    func testDeleteNota() async throws {
        let viewModel = try XCTUnwrap(viewModel)
        try await createNota()
        
        let index = IndexSet(integer: 0)
        await viewModel.deleteNota(index)
        await viewModel.refreshNotas(with: .all)
        
        XCTAssert(viewModel.notas.isEmpty, "La nota ya no debe estar en el array")
    }
    
    @MainActor
    func testFilteringNota() async throws {
        let viewModel = try XCTUnwrap(viewModel)
        var nota1 = try await createNota()
        nota1.title = "123 saving 523"
        nota1.body = "random 000"
        await viewModel.updateNota(nota1, force: true)
        
        var nota2 = try await createNota()
        nota2.title = "--=-random=---="
        await viewModel.updateNota(nota2, force: true)
        
        viewModel.searchQuery = "123"
        await viewModel.refreshNotas(with: .search(viewModel.searchQuery))
        
        XCTAssertEqual(viewModel.notas.count, 1, "Esta busqueda debe retornar solo un valor")
        
        viewModel.searchQuery = "random"
        await viewModel.refreshNotas(with: .search(viewModel.searchQuery))
        
        XCTAssertEqual(viewModel.notas.count, 2, "Esta busqueda debe retornar 2 valores")
    }
}
