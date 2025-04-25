import UIKit
import Foundation
import Combine

class APIService {
    private let decoder = JSONDecoder()
    private let endpoint = "https://pokeapi.co/api/v2/"
    private let imagesEndpoint = """
        https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/
    """

    init() {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func fetchLightPokemons(offset: UInt = 0) -> AnyPublisher<[LightResource], APIError> {
        return decodedDataPublisher(for: endpoint + "pokemon?offset=\(offset)", decodeToType: [LightResource].self)
    }

    func fetchPokemon(from resource: LightResource) -> AnyPublisher<APIPokemon, APIError> {
        return decodedDataPublisher(for: resource.url, decodeToType: APIPokemon.self)
    }

    func fetchEvolution() -> AnyPublisher<[Int], APIError> {
        fatalError("Not implemented")
    }

    func fetchPokemonImage(byID pokemonID: UInt) -> AnyPublisher<UIImage, APIError> {
        return createTaskPublisher(for: imagesEndpoint + "\(pokemonID).png")
            .map { UIImage(data: $0) ?? .pokeball }
            .mapError { ($0 as? APIError) ?? .badResponse }
            .eraseToAnyPublisher()
    }

    private func decodedDataPublisher<T: Decodable>(
        for query: String,
        decodeToType type: T.Type
    ) -> AnyPublisher<T, APIError> {
        return createTaskPublisher(for: query)
            .decode(type: type, decoder: decoder)
            .mapError { ($0 as? APIError) ?? .badResponse }
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
