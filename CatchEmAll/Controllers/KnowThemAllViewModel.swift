import Combine

class KnowThemAllViewModel<DP: DataProvider> {
    private let dataProvider: DP
    private var offset = 0

    init(dataProvider: DP) {
        self.dataProvider = dataProvider
    }

    func getPokemonForCollection() -> AnyPublisher<[PokemonLight], Error> {
        return dataProvider.getPokemons(offset: offset)
            .handleEvents(receiveOutput: { [weak self] _ in self?.offset += 20 })
            .map { $0.map { pokemon in pokemon.light() } }
            .eraseToAnyPublisher()
    }
}
