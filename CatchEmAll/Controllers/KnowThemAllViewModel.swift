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
        fetchItems(with: paginationService.current)
    }

    func updateDataIfNeeded(with itemID: UInt) {
        guard paginationService.shouldRequestMore(for: itemID) else { return }
        paginationService.moveForward { [weak self] in self?.fetchItems(with: $0) }
    }

    func fetchItems(with pagination: PaginationService.Pagination) {
        dataProvider.getPokemons(offset: pagination.offset, limit: pagination.limit)
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
