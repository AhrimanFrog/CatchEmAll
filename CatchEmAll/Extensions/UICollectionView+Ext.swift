import UIKit

extension UICollectionView {
    func deque<Cell: UICollectionViewCell & ReuseIdentifiable>(
        _ type: Cell.Type,
        for indexPath: IndexPath,
        configure: (Cell) -> Void
    ) -> Cell { // swiftlint:disable:next force_cast
        let cell = dequeueReusableCell(withReuseIdentifier: type.reuseID, for: indexPath) as! Cell
        configure(cell)
        return cell
    }

    func register<Cell: UICollectionViewCell & ReuseIdentifiable>(_ type: Cell.Type) {
        register(type, forCellWithReuseIdentifier: type.reuseID)
    }
}
