import UIKit
import Foundation
import Combine
import CoreData

class APIService: APIProvider {
    private let decoder = JSONDecoder()
    private let endpoint = "https://pokeapi.co/api/v2/"
    private let imagesEndpoint = """
        https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/
    """.trimmingCharacters(in: .whitespacesAndNewlines)

    init() {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func fetchLightPokemons(offset: UInt = 0) -> AnyPublisher<LightPokemonResponse, APIError> {
        return decodedDataPublisher(
            for: endpoint + "pokemon?offset=\(offset)", decodeToType: LightPokemonResponse.self
        )
    }

    func fetchPokemon(from resource: LightResource) -> AnyPublisher<APIPokemon, APIError> {
        return decodedDataPublisher(for: resource.url, decodeToType: APIPokemon.self)
    }

    func fetchPokemons(offset: UInt = 0) -> AnyPublisher<[APIPokemon], APIError> {
        return fetchLightPokemons(offset: offset)
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

    func fetchEvolution() -> AnyPublisher<[Int], APIError> {
        fatalError("Not implemented")
    }

    func fetchPokemonImage(byID pokemonID: UInt) -> AnyPublisher<Data, Never> {
        return createTaskPublisher(for: imagesEndpoint + "\(pokemonID).png")
            .replaceError(with: Data())
            .eraseToAnyPublisher()
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
        return URLSession.shared.dataTaskPublisher(for: url)
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
