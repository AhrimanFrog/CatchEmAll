import Combine
import UIKit

class DataService<API: APIProvider, DB: DBProvider>: DataProvider {
    private let apiProvider: API
    private let dbProvider: DB

    init(apiProvider: API, dbProvider: DB) {
        self.apiProvider = apiProvider
        self.dbProvider = dbProvider
    }

    func getPokemons(offset: UInt, limit: UInt) -> AnyPublisher<[Pokemon], any Error> {
        if let dbPokemon = dbProvider.retrievePokemon(offset: offset, limit: limit), !dbPokemon.isEmpty {
            return Just(dbPokemon.map { Pokemon.fromDBData($0) })
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return apiProvider.fetchPokemons(offset: offset, limit: limit)
            .handleEvents(receiveOutput: { [weak self] apiPokemon in
                apiPokemon.forEach { self?.dbProvider.preservePokemon($0) }
            })
            .map { result in result.map { $0.toUIPokemon() } }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }

    func getPokemonImage(byID id: UInt) -> AnyPublisher<Data, Never> {
        if let pokemonImageData = dbProvider.retrieveImage(byID: id) {
            return Just(pokemonImageData).eraseToAnyPublisher()
        }
        return apiProvider.fetchPokemonImage(byID: id)
            .handleEvents(receiveOutput: { [weak self] in self?.dbProvider.preserveImage($0, withID: id) })
            .eraseToAnyPublisher()
    }
}
