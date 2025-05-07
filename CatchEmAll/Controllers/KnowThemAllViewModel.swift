import Combine
import UIKit

class KnowThemAllViewModel<DP: DataProvider>: CollectionItemsProvider {
    private let dataProvider: DP
    private let paginationService = PaginationService() // temp
    private var subscriptions = Set<AnyCancellable>()

    let items: CurrentValueSubject<[PokemonLight], Never> = .init([])
    var onErrorOccur: ((any Error) -> Void)?

    init(dataProvider: DP) {
        self.dataProvider = dataProvider
        fetchItems(offset: paginationService.offset, limit: paginationService.limit)
    }

    func updateDataIfNeeded(with itemID: UInt) {
        guard paginationService.shouldRequestMore(for: itemID) else { return }
        paginationService.moveForward { [weak self] in self?.fetchItems(offset: $0.offset, limit: $0.limit) }
    }

    private func fetchItems(offset: UInt, limit: UInt) {
        dataProvider.getPokemons(offset: offset, limit: limit)
            .mapError { $0 as Error }
            .map { $0.map { pokemon in pokemon.light() }.sorted { $0.id < $1.id } }
            .sink { [weak self] result in
                switch result {
                case .success(let pokemon): self?.items.value.append(contentsOf: pokemon)
                case .failure(let error): self?.onErrorOccur?(error)
                }
            }
            .store(in: &subscriptions)
    }

    func getCellImage(byID id: UInt) -> AnyPublisher<UIImage, Never> {
        return dataProvider.getPokemonImage(byID: id)
            .map { UIImage(data: $0) ?? .pokeball }
            .eraseToAnyPublisher()
    }
}
