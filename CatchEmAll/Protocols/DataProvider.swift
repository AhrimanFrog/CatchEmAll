import Combine
import UIKit

protocol DataProvider {
    func getPokemon(byID pokemonID: UInt) -> AnyPublisher<Pokemon, Error>
    func getPokemons(offset: UInt, limit: UInt) -> AnyPublisher<[Pokemon], Error>
    func getPokemonImage(byID id: UInt) -> AnyPublisher<Data, Never>
}
