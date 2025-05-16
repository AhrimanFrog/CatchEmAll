import Combine
import UIKit

protocol APIProvider {
    func fetchPokemons(offset: UInt, limit: UInt) -> AnyPublisher<[APIPokemon], APIError>
    func fetchPokemonImage(byID pokemonID: UInt) -> AnyPublisher<Data, Never>
    func fetchPokemon(byID pokemonID: UInt) -> AnyPublisher<APIPokemon, APIError>
    func fetchEvolution(byPokemonID pokeID: UInt) -> AnyPublisher<[UInt], APIError>
}
