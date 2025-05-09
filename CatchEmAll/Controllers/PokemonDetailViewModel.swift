import Combine

class PokemonDetailViewModel {
    private let dataProvider: DataProvider

    init(dataService: some DataProvider, pokemonID: UInt) {
        self.dataProvider = dataService
    }
}
