import Combine

class PokemonDetailViewModel {
    private let dataProvider: DataProvider
    private let pokemonID: UInt

    init(dataService: some DataProvider, pokemonID: UInt) {
        self.dataProvider = dataService
        self.pokemonID = pokemonID
    }

    func requestInfo() -> AnyPublisher<Pokemon, DBError> {
        return dataProvider.getPokemon(byID: pokemonID)
    }
}
