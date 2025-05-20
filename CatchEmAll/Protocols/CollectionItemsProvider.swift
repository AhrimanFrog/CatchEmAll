import Combine
import UIKit

protocol CollectionItemsProvider {
    associatedtype ItemsType
    var items: CurrentValueSubject<ItemsType, Never> { get }
    func getCellImage(byID id: UInt) -> AnyPublisher<Data, Never>
    func updateDataIfNeeded(with: UInt)
    var navigationDispatcher: NavigationDispatcher { get }
}
