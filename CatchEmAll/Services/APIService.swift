import Foundation
import Combine
import CoreData

class APIService: APIProvider {
    private let session: URLSession
    private let decoder = JSONDecoder()
    private let endpoint = "https://pokeapi.co/api/v2/"
    private let imagesEndpoint = """
        https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/
    """.trimmingCharacters(in: .whitespacesAndNewlines)

    init(session: URLSession = .shared) {
        self.session = session
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func fetchPokemons(offset: UInt, limit: UInt) -> AnyPublisher<[APIPokemon], APIError> {
        return fetchLightPokemons(offset: offset, limit: limit)
            .flatMap { [weak self] response in
                guard let self else {
                    return Fail<[APIPokemon], APIError>(error: APIError.badRequest).eraseToAnyPublisher()
                }
                return Publishers.MergeMany(response.results.map { self.fetchPokemon(from: $0) })
                    .collect()
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func fetchEvolution(byPokemonID pokeID: UInt) -> AnyPublisher<[UInt], APIError> {
        return decodedDataPublisher(for: endpoint + "pokemon-species/\(pokeID)", decodeToType: APISpecies.self)
        .flatMap { [weak self] speciesResponse in
            guard let self else {
                return Fail<APIEvolutionChainResponse, APIError>(error: APIError.badResponse).eraseToAnyPublisher()
            }
            let evolutionQuery = speciesResponse.evolutionChain.url
            return decodedDataPublisher(for: evolutionQuery, decodeToType: APIEvolutionChainResponse.self)
        }
        .map { EvoltionDecoder.decodeEvolution(fromChain: $0.chain) }
        .eraseToAnyPublisher()
    }

    func fetchPokemonImage(byID pokemonID: UInt) -> AnyPublisher<Data, Never> {
        return createTaskPublisher(for: imagesEndpoint + "\(pokemonID).png")
            .replaceError(with: Data())
            .eraseToAnyPublisher()
    }

    func fetchPokemon(byID pokemonID: UInt) -> AnyPublisher<APIPokemon, APIError> {
        return decodedDataPublisher(for: endpoint + "pokemon/\(pokemonID)", decodeToType: APIPokemon.self)
    }

    private func fetchLightPokemons(offset: UInt, limit: UInt) -> AnyPublisher<LightPokemonResponse, APIError> {
        return decodedDataPublisher(
            for: endpoint + "pokemon?offset=\(offset)&limit=\(limit)", decodeToType: LightPokemonResponse.self
        )
    }

    private func fetchPokemon(from resource: LightResource) -> AnyPublisher<APIPokemon, APIError> {
        return decodedDataPublisher(for: resource.url.absoluteString, decodeToType: APIPokemon.self)
    }

    private func decodedDataPublisher<T: Decodable>(
        for query: String,
        decodeToType type: T.Type
    ) -> AnyPublisher<T, APIError> {
        return createTaskPublisher(for: query)
            .decode(type: type, decoder: decoder)
            .mapError { ($0 as? APIError) ?? .invalidData }
            .eraseToAnyPublisher()
    }

    private func createTaskPublisher(for query: String) -> AnyPublisher<Data, Error> {
        guard let url = URL(string: query) else { return Fail(error: APIError.badRequest).eraseToAnyPublisher() }
        return session.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else { throw APIError.badResponse }
                guard httpResponse.statusCode == 200 else {
                    throw APIError.wrongStatusCode(httpResponse.statusCode)
                }
                return data
            }
            .eraseToAnyPublisher()
    }
}
