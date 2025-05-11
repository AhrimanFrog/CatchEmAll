import Combine

class PokemonDetailViewModel {
    private let dataProvider: DataProvider
    private let pokemonID: UInt

    init(dataService: some DataProvider, pokemonID: UInt) {
        self.dataProvider = dataService
        self.pokemonID = pokemonID
    }

    func requestInfo() -> AnyPublisher<Pokemon, Error> {
        return dataProvider.getPokemon(byID: pokemonID)
    }

    func requestStats() -> AnyPublisher<[String], DBError> {
        fatalError()
    }

    func requestMoves() -> AnyPublisher<[String], DBError> {
        fatalError()
    }

    func requestEvolution() {
        fatalError()
    }
}
