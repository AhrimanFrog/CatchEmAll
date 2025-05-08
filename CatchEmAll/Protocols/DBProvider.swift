import Combine
import Foundation

protocol DBProvider {
    func preservePokemon(_ pokemon: APIPokemon)
    func retrievePokemon(offset: UInt, limit: UInt) -> AnyPublisher<[DBPokemon], DBError>
    func preserveImage(_ image: Data, withID imageId: UInt)
    func retrieveImage(byID imageID: UInt) -> AnyPublisher<Data, DBError>
}
