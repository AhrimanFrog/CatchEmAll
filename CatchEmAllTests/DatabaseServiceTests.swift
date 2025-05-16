import XCTest
import CoreData
import Combine
@testable import CatchEmAll

class DatabaseServiceTests: XCTestCase {
    var service: DatabaseService!
    var container: NSPersistentContainer!
    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        cancellables = []

        container = NSPersistentContainer(name: "CatchEmAll")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }

        service = DatabaseService(container: container)
    }

    override func tearDown() {
        service = nil
        container = nil
        cancellables.removeAll()
        super.tearDown()
    }

    func testPreserveAndRetrieveImage() {
        let imageId: UInt = 42
        let sampleData = "testImage".data(using: .utf8)!

        let expectation = self.expectation(description: "RetrieveImage")

        service.preserveImage(sampleData, withID: imageId)

        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            self.service.retrieveImage(byID: imageId)
                .sink { result in
                    switch result {
                    case .failure(let error):
                        XCTFail("Unexpected error: \(error)")
                    case .success(let data):
                        XCTAssertEqual(data, sampleData)
                        expectation.fulfill()
                    }
                }
                .store(in: &self.cancellables)
        }

        wait(for: [expectation], timeout: 2)
    }

    func testPreserveAndRetrievePokemon() {
        let expectation = self.expectation(description: "RetrievePokemon")

        let pokemon = Pokemon(
            id: 1,
            name: "Bulbasaur",
            height: 7,
            weight: 69,
            abilities: ["overgrow"],
            moves: ["tackle"],
            stats: [Stat(value: 45, name: "hp")]
        )

        service.preservePokemon(pokemon)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.service.retrievePokemon(offset: 0, limit: 10)
                .sink { result in
                    switch result {
                    case .failure(let error):
                        XCTFail("Unexpected error: \(error)")
                    case .success(let pokemons):
                        XCTAssertFalse(pokemons.isEmpty)
                        XCTAssertEqual(pokemons.first?.id, Int64(pokemon.id))
                        expectation.fulfill()
                    }
                }
                .store(in: &self.cancellables)
        }

        wait(for: [expectation], timeout: 2)
    }

    func testPreserveAndRetrieveEvolutionChain() {
        let expectation = expectation(description: "RetrieveEvolution")

        let pokemonID: UInt = 7
        let evolutionChain: [UInt] = [7, 8, 9]

        let pokemon = Pokemon(
            id: 7,
            name: "Squirtle",
            height: 5,
            weight: 90,
            abilities: [],
            moves: [],
            stats: []
        )
        service.preservePokemon(pokemon)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.service.preserveEvolution(chain: evolutionChain, forPokemonID: pokemonID)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.service.retrieveEvolutionChain(byPokemonID: pokemonID)
                    .sink { result in
                        switch result {
                        case .failure(let error):
                            XCTFail("Unexpected error: \(error)")
                        case .success(let chain):
                            XCTAssertEqual(chain, evolutionChain)
                            expectation.fulfill()
                        }
                    }
                    .store(in: &self.cancellables)
            }
        }

        wait(for: [expectation], timeout: 3)
    }
}
