import Combine
import UIKit

protocol CollectionItemsProvider {
    func getPokemonForCollection() -> AnyPublisher<[PokemonLight], Error>
    func getPokemonImage(byID id: UInt) -> AnyPublisher<UIImage, Never>
}
