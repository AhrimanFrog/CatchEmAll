import Combine
import UIKit

protocol APIProvider {
    func fetchPokemons(offset: UInt, limit: UInt) -> AnyPublisher<[APIPokemon], APIError>
    func fetchPokemonImage(byID pokemonID: UInt) -> AnyPublisher<Data, Never>
}
