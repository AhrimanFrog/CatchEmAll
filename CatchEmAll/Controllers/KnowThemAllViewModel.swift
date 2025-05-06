import Combine
import UIKit

class KnowThemAllViewModel<DP: DataProvider>: CollectionItemsProvider {
    private let dataProvider: DP
    private var offset: UInt = 0
    private var subscriptions = Set<AnyCancellable>()

    let items: CurrentValueSubject<[PokemonLight], Never> = .init([])
    var onErrorOccur: ((any Error) -> Void)?

    init(dataProvider: DP) {
        self.dataProvider = dataProvider
    }

    func fetchItems() {
        dataProvider.getPokemons(offset: offset)
            .mapError { $0 as Error }
            .map { $0.map { pokemon in pokemon.light() } }
            .sink { [weak self] result in
                switch result {
                case .success(let pokemon): self?.items.value.append(contentsOf: pokemon)
                case .failure(let error): self?.onErrorOccur?(error)
                }
                self?.offset += 36
            }
            .store(in: &subscriptions)
    }

    func getCellImage(byID id: UInt) -> AnyPublisher<UIImage, Never> {
        return dataProvider.getPokemonImage(byID: id)
            .map { UIImage(data: $0) ?? .pokeball }
            .eraseToAnyPublisher()
    }
}
