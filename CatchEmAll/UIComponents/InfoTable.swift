import UIKit
import Combine

class InfoTable<DataProvider: CollectionItemsProvider & SectionSelectable>: UITableView {
    private var diffDataSource: UITableViewDiffableDataSource<Int, TableItem>?
    private var itemProvider: DataProvider
    private var dataSubscription: AnyCancellable?

    init(itemProvider: DataProvider) {
        self.itemProvider = itemProvider
        super.init(frame: .zero, style: .plain)
        register(EvolutionCell.self)
        register(InfoCell.self)
        initDataSource()
        dataSubscription = itemProvider.items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.updateTable(withInfo: ($0 as? [TableItem]) ?? []) }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initDataSource() {
        diffDataSource = .init(tableView: self) { [itemProvider] tableView, indexPath, tableItem in
            if itemProvider.section == .evolution {
                return tableView.deque(EvolutionCell.self, for: indexPath) {
                    $0.setData(
                        text: tableItem.value,
                        imagePublisher: itemProvider.getCellImage(byID: UInt(tableItem.name) ?? 0)
                    )
                }
            }
            return tableView.deque(InfoCell.self, for: indexPath) {
                $0.setText(title: tableItem.name, body: tableItem.value)
            }
        }
    }

    private func updateTable(withInfo info: [TableItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, TableItem>()
        snapshot.appendSections([0])
        snapshot.appendItems(info, toSection: 0)
        diffDataSource?.apply(snapshot)
    }
}
