import Combine

class PokemonDetailViewModel {
    private let dataProvider: DataProvider
    private let pokemonID: UInt
    private let navigationDispatcher: NavigationDispatcher
    private var subscriptions = Set<AnyCancellable>()

    @Published var pokemon: Pokemon?

    init(dataService: some DataProvider, pokemonID: UInt, navigationDispatcher: NavigationDispatcher) {
        self.dataProvider = dataService
        self.navigationDispatcher = navigationDispatcher
        self.pokemonID = pokemonID
    }

    func requestInfo() {
        dataProvider.getPokemon(byID: pokemonID)
            .handleEvents(receiveOutput: { [weak self] pokemon in
                guard let self else { return }
                dataProvider.getEvolution(byPokemonID: pokemon.id)
                    .sink { [weak self] in self?.pokemon?.evolutions = $0 }
                    .store(in: &subscriptions)
            })
            .sink { [weak self] result in
                switch result {
                case .success(let pokemon): self?.pokemon = pokemon
                case .failure(let error): self?.navigationDispatcher.onErrorOccur(error)
                }
            }
            .store(in: &subscriptions)
    }
}
