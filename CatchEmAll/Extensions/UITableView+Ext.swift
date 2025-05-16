import UIKit

extension UITableView {
    func deque<Cell: UITableViewCell & ReuseIdentifiable>(
        _ type: Cell.Type,
        for indexPath: IndexPath,
        configure: (Cell) -> Void
    ) -> Cell { // swiftlint:disable:next force_cast
        let cell = dequeueReusableCell(withIdentifier: type.reuseID, for: indexPath) as! Cell
        configure(cell)
        return cell
    }

    func register<Cell: UITableViewCell & ReuseIdentifiable>(_ type: Cell.Type) {
        register(type, forCellReuseIdentifier: type.reuseID)
    }
}
