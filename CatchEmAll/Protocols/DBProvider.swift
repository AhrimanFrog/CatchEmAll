import UIKit

protocol DBProvider {
    func preservePokemon(_ pokemon: APIPokemon)
    func retrievePokemon(offset: UInt, limit: UInt) -> [DBPokemon]?
    func preserveImage(_ image: Data, withID imageId: UInt)
    func retrieveImage(byID imageID: UInt) -> Data?
}
