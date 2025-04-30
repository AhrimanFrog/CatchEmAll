import Combine
import UIKit

protocol DataProvider {
    func getPokemons(offset: UInt) -> AnyPublisher<[Pokemon], Error>
    func getPokemonImage(byID id: UInt) -> AnyPublisher<UIImage, Never>
}
