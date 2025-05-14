import SnapKit
import UIKit
import HMSegmentedControl

class PokemonDetail: UIViewController {
    private let name = UILabel()
    private let image = UIImageView(image: .pokeball)
    lazy var segmentedControl: HMSegmentedControl = {
        let control = HMSegmentedControl(
            sectionTitles: DetailsSection.allCases.map { $0.rawValue.capitalized }
        )
        control.selectionIndicatorHeight = 1.5
        control.selectionIndicatorColor = .systemRed
        control.backgroundColor = .clear
        control.selectionIndicatorLocation = .bottom
        control.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.label,
            NSAttributedString.Key.font: UIFont.lato(ofSize: 16)
        ]
        control.selectedTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.systemRed,
            NSAttributedString.Key.font: UIFont.lato(ofSize: 16)
        ]
        return control
    }()
    private let infoTable: InfoTable<PokemonDetailViewModel>

    private let viewModel: PokemonDetailViewModel

    init(viewModel: PokemonDetailViewModel, pokemonImage: UIImage) {
        self.viewModel = viewModel
        self.infoTable = .init(itemProvider: viewModel)
        super.init(nibName: nil, bundle: nil)
        image.image = pokemonImage
        configure()
        setConstraints()
        viewModel.subscribeToSectionUpdates(
            sectionPublisher: segmentedControl
                .publisher(for: \.selectedSegmentIndex)
                .eraseToAnyPublisher()
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        image.contentMode = .scaleAspectFit
        view.backgroundColor = .systemBackground
        navigationItem.backButtonTitle = ""
    }

    private func setConstraints() {
        view.addSubviews(name, image, segmentedControl, infoTable)
        name.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(24)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(95)
            make.height.lessThanOrEqualTo(29)
        }
        image.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(15)
            make.top.equalTo(name.snp.bottom).offset(40)
            make.height.lessThanOrEqualTo(200)
        }
        segmentedControl.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(24)
            make.top.equalTo(image.snp.bottom).offset(20)
            make.height.lessThanOrEqualTo(24)
        }
        infoTable.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(37)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(segmentedControl.snp.bottom).offset(13)
        }
    }
}
