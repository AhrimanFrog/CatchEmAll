import Combine
import UIKit
import os

class KnowThemAllViewModel<DP: DataProvider>: CollectionItemsProvider {
    let items: CurrentValueSubject<[PokemonLight], Never> = .init([])
    var onErrorOccur: ((any Error) -> Void)?

    private let dataProvider: DP
    private lazy var paginationService = PaginationService(
        isProcessingAvailable: { [weak self] in
            guard let self else { return false }
            return !isLoading
        },
        getItemsCount: { [weak self] in
            guard let self else { return 0 }
            return UInt(items.value.count)
        }
    )
    private var subscriptions = Set<AnyCancellable>()

    private let lock = OSAllocatedUnfairLock()
    private var _isLoading = false
    private(set) var isLoading: Bool {
        get { lock.withLock { _isLoading } }
        set { lock.withLock { _isLoading = newValue } }
    }

    init(dataProvider: DP) {
        self.dataProvider = dataProvider
        bind()
        paginationService.requestMoreIfNeeded(for: 0)
    }

    func updateDataIfNeeded(with itemID: UInt) {
        paginationService.requestMoreIfNeeded(for: itemID)
    }

    private func bind() {
        paginationService.requestMorePubl
            .flatMap { [dataProvider] offset, limit -> AnyPublisher<Result<[PokemonLight], Error>, Never> in
                dataProvider.getPokemons(offset: offset, limit: limit)
                    .handleEvents(
                        receiveSubscription: { [weak self] _ in self?.isLoading = true },
                        receiveCompletion: { [weak self] _ in self?.isLoading = false }
                    )
                    .mapError { $0 as Error }
                    .map { .success($0.map { pokemon in pokemon.light() }.sorted { $0.id < $1.id }) }
                    .catch { error in Just(.failure(error)) }
                    .eraseToAnyPublisher()
            }
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
