import Combine
import UIKit

class DataService<API: APIProvider, DB: DBProvider>: DataProvider {
    private let apiProvider: API
    private let dbProvider: DB

    init(apiProvider: API, dbProvider: DB) {
        self.apiProvider = apiProvider
        self.dbProvider = dbProvider
    }

    func getPokemons(offset: UInt = 0) -> AnyPublisher<[Pokemon], any Error> {
        return apiProvider.fetchPokemons(offset: offset)
            .map { result in result.map { $0.toUIPokemon() } }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }

    func getPokemonImage(byID id: UInt) -> AnyPublisher<UIImage, Never> {
        return apiProvider.fetchPokemonImage(byID: id)
    }
}
