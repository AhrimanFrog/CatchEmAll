import Foundation

protocol ReuseIdentifiable {
    static var reuseID: String { get }
}

extension ReuseIdentifiable {
    static var reuseID: String { .init(describing: self) }
}
