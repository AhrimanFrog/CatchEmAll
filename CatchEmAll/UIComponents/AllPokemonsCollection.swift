import UIKit

class AllPokemonsCollection: UICollectionView {
    private var diffDataSource: UICollectionViewDiffableDataSource<Int, String>?

    init() {
        super.init(frame: .zero, collectionViewLayout: .twoPerRow())
        initDataSource()
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
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let layout = collectionViewLayout as? UICollectionViewFlowLayout
        let collectionWidth = collectionView.frame.width
        let horizontalPadding = layout?.sectionInset.horizontal ?? 0
        let interitemSpacing = layout?.minimumInteritemSpacing ?? 0
        let width = (collectionWidth - horizontalPadding - interitemSpacing) / 2

        return .init(width: width, height: width * 0.675)
    }
}
