import UIKit

class AllPokemonsCollection: UICollectionView {
    private var diffDataSource: UICollectionViewDiffableDataSource<Int, String>?
    private var cachedCellWidth: Double?

    init() {
        super.init(frame: .zero, collectionViewLayout: .vertical())
        initDataSource()
        delegate = self
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initDataSource() {
    }

    private func updateUI() {
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
