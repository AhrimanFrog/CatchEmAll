import Combine
import UIKit

class AllPokemonsCollection: UICollectionView {
    private var diffDataSource: UICollectionViewDiffableDataSource<Int, PokemonLight>?
    private var cachedCellWidth: Double?
    private var itemProvider: CollectionItemsProvider
    private var dataSubscription: AnyCancellable?

    init(itemProvider: CollectionItemsProvider) {
        self.itemProvider = itemProvider
        super.init(frame: .zero, collectionViewLayout: .vertical())
        initDataSource()
        register(PokemonPreviewCell.self)
        delegate = self
        backgroundColor = .clear
        dataSubscription = itemProvider.items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.updateUI(withItems: $0) }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initDataSource() {
        diffDataSource = .init(collectionView: self) { [itemProvider] collection, index, pokemon in
            return collection.deque(PokemonPreviewCell.self, for: index) { cell in
                cell.setPokemon(pokemon)
                cell.subscribeToImage(itemProvider.getCellImage(byID: pokemon.id))
                cell.onTouch = { image in itemProvider.onItemSelection(image, pokemon.id) }
                itemProvider.updateDataIfNeeded(with: pokemon.id)
            }
        }
    }

    private func updateUI(withItems items: [PokemonLight]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, PokemonLight>()
        snapshot.appendSections([0])
        snapshot.appendItems(items, toSection: 0)
        diffDataSource?.apply(snapshot, animatingDifferences: true)
    }
}

extension AllPokemonsCollection: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt: IndexPath
    ) -> CGSize {
        if let cachedCellWidth {
            return .init(width: cachedCellWidth, height: cachedCellWidth * 0.675)
        }

        let layout = collectionViewLayout as? UICollectionViewFlowLayout
        let collectionWidth = collectionView.frame.width
        let horizontalPadding = layout?.sectionInset.horizontal ?? 0
        let interitemSpacing = layout?.minimumInteritemSpacing ?? 0
        let width = (collectionWidth - horizontalPadding - interitemSpacing) / 2
        cachedCellWidth = width
        return .init(width: width, height: width * 0.675)
    }
}
