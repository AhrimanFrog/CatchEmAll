import Combine
import UIKit

class KnowThemAllViewModel<DP: DataProvider>: CollectionItemsProvider {
    private let dataProvider: DP
    private var offset: UInt = 0

    init(dataProvider: DP) {
        self.dataProvider = dataProvider
    }

    func getPokemonForCollection() -> AnyPublisher<[PokemonLight], Error> {
        return dataProvider.getPokemons(offset: offset) // swiftlint:disable:next trailing_closure
            .handleEvents(receiveOutput: { [weak self] _ in self?.offset += 100 })
            .mapError { $0 as Error }
            .map { $0.map { pokemon in pokemon.light() } }
            .eraseToAnyPublisher()
    }

    func getPokemonImage(byID id: UInt) -> AnyPublisher<UIImage, Never> {
        return dataProvider.getPokemonImage(byID: id)
    }
}
