import Combine
import UIKit

class PokemonDetailViewModel: CollectionItemsProvider, SectionSelectable {
    private let dataProvider: DataProvider
    private let pokemonID: UInt
    private var subscriptions = Set<AnyCancellable>()

    @Published var pokemon: Pokemon?
    var section: DetailsSection = .about
    let items: CurrentValueSubject<[TableItem], Never> = .init([])
    let navigationDispatcher: NavigationDispatcher

    init(dataService: some DataProvider, pokemonID: UInt, navigationDispatcher: NavigationDispatcher) {
        self.dataProvider = dataService
        self.navigationDispatcher = navigationDispatcher
        self.pokemonID = pokemonID
        requestInfo()
    }

    func requestInfo() {
        dataProvider.getPokemon(byID: pokemonID)
            .flatMap { [weak self] pokemon -> AnyPublisher<(Pokemon, [PokemonLight]), Never> in
                guard let self else { return Just((pokemon, [])).eraseToAnyPublisher() }
                return dataProvider.getEvolution(byPokemonID: pokemon.id)
                    .map { (pokemon, $0) }
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] result in
                switch result {
                case .success(let (pokemon, evolutions)):
                    self?.pokemon = pokemon
                    self?.pokemon?.evolutions = evolutions
                case .failure(let error): self?.navigationDispatcher.onErrorOccur(error)
                }
            }
            .store(in: &subscriptions)
    }

    func getCellImage(byID id: UInt) -> AnyPublisher<UIImage, Never> {
        dataProvider.getPokemonImage(byID: id)
            .map { UIImage(data: $0) ?? .pokeball }
            .eraseToAnyPublisher()
    }

    func updateDataIfNeeded(with sectionIndex: UInt) {
        section = DetailsSection.allCases[Int(sectionIndex)]
        let newItems = switch section {
        case .about: generalInfo()
        case .stats: uiStats()
        case .evolution: uiEvolution()
        case .moves: uiMoves()
        }
        items.send(newItems)
    }

    func subscribeToSectionUpdates(sectionPublisher: AnyPublisher<UInt, Never>) {
        sectionPublisher
            .sink { [weak self] sectionIndex in self?.updateDataIfNeeded(with: sectionIndex) }
            .store(in: &subscriptions)
    }

    private func generalInfo() -> [TableItem] {
        guard let pokemon else { return [] }
        return [
            TableItem(name: "Height", value: String(pokemon.height)),
            TableItem(name: "Weight", value: String(pokemon.weight)),
            TableItem(name: "Attack", value: String(pokemon.attack)),
            TableItem(name: "Damage", value: String(pokemon.damage)),
            TableItem(name: "Abilities", value: pokemon.abilities.joined(separator: ", "))
        ]
    }

    private func uiMoves() -> [TableItem] {
        guard let pokemon else { return [] }
        return pokemon.moves.enumerated().map { TableItem(name: String($0.offset), value: $0.element) }
    }

    private func uiStats() -> [TableItem] {
        guard let pokemon else { return [] }
        return pokemon.stats.map { TableItem(name: $0.name, value: String($0.value)) }
    }

    private func uiEvolution() -> [TableItem] {
        guard let pokemon, let evolutions = pokemon.evolutions else { return [] }
        return evolutions.map { TableItem(name: String($0.id), value: $0.name) }
    }
}
