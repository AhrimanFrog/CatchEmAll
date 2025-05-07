import Combine
import UIKit

protocol CollectionItemsProvider {
    func getCellImage(byID id: UInt) -> AnyPublisher<UIImage, Never>
    func updateDataIfNeeded(with itemID: UInt)
    var items: CurrentValueSubject<[PokemonLight], Never> { get }
    var onErrorOccur: ((Error) -> Void)? { get set }
}
