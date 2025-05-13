import Combine
import Foundation

protocol DBProvider {
    func preservePokemon(_ pokemon: Pokemon)
    func retrievePokemon(offset: UInt, limit: UInt) -> AnyPublisher<[DBPokemon], DBError>
    func retrievePokemon(byID pokemonID: UInt) -> AnyPublisher<DBPokemon, DBError>
    func preserveImage(_ image: Data, withID imageId: UInt)
    func retrieveImage(byID imageID: UInt) -> AnyPublisher<Data, DBError>
    func retrieveEvolutionChain(byPokemonID pokemonID: UInt) -> AnyPublisher<[UInt], DBError>
    func preserveEvolution(chain: [UInt], forPokemonID pokemonID: UInt)
}
