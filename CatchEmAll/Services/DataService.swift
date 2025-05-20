import Combine
import Foundation

class DataService: DataProvider {
    private let apiProvider: APIProvider
    private let dbProvider: DBProvider

    init(apiProvider: APIProvider, dbProvider: DBProvider) {
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

    func getEvolution(byPokemonID pokemonID: UInt) -> AnyPublisher<[PokemonLight], Never> {
        return dbProvider.retrieveEvolutionChain(byPokemonID: pokemonID)
            .catch { [weak self] _ in
                guard let self else {
                    return Fail<[UInt], Error>(error: APIError.networkProblem as Error).eraseToAnyPublisher()
                }
                return apiProvider.fetchEvolution(byPokemonID: pokemonID)
                    .handleEvents(receiveOutput: { [weak self] in
                        self?.dbProvider.preserveEvolution(chain: $0, forPokemonID: pokemonID)
                    })
                    .mapError { $0 as Error }
                    .eraseToAnyPublisher()
            }
            .flatMap { [weak self] evolutionIDs in
                let pokePublishers = evolutionIDs.compactMap { self?.getPokemon(byID: $0) }
                return Publishers.MergeMany(pokePublishers).collect().eraseToAnyPublisher()
            }
            .map { pokemon in pokemon.map { $0.light() } }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
}
