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
        return dbProvider.retrievePokemon(offset: offset, limit: limit)
            .map { result in result.map(Pokemon.fromDBData) }
            .catch { [apiProvider] _ in
                apiProvider.fetchPokemons(offset: offset, limit: limit)
                    .map { $0.map(Pokemon.fromAPIData(_:)) }
                    .handleEvents(receiveOutput: { [weak self] apiPokemon in
                        apiPokemon.forEach { self?.dbProvider.preservePokemon($0) }
                    })
                    .mapError { $0 as Error }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func getPokemon(byID pokemonID: UInt) -> AnyPublisher<Pokemon, Error> {
        return dbProvider.retrievePokemon(byID: pokemonID)
            .map(Pokemon.fromDBData(_:))
            .tryCatch { [apiProvider] error in
                guard error == .notFound else { throw (error as Error) }
                return apiProvider.fetchPokemon(byID: pokemonID)
                    .map(Pokemon.fromAPIData(_:))
                    .mapError { $0 as Error }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func getPokemonImage(byID id: UInt) -> AnyPublisher<Data, Never> {
        return dbProvider.retrieveImage(byID: id)
            .catch { [apiProvider] _ in
                apiProvider.fetchPokemonImage(byID: id)
                    .handleEvents(receiveOutput: { [weak self] in
                        self?.dbProvider.preserveImage($0, withID: id)
                    })
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
