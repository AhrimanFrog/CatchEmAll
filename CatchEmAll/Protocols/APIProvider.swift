import Combine

protocol APIProvider {
    func fetchPokemons(offset: UInt) -> AnyPublisher<[APIPokemon], APIError>
}
