import UIKit
import Combine
import SnapKit

class EvolutionCell: UITableViewCell, ReuseIdentifiable {
    let image = UIImageView(image: .pokeball)
    private let bodyLabel = UILabel()

    private var imageSubscription: AnyCancellable?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setConstraints()
        configure()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageSubscription?.cancel()
        bodyLabel.text = ""
    }

    func setData(text: String, imagePublisher: AnyPublisher<UIImage, Never>) {
        bodyLabel.text = text
        imageSubscription = imagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in self?.image.image = image }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        image.contentMode = .scaleAspectFit
        bodyLabel.font = .lato(ofSize: 18)
        selectionStyle = .none
    }

    private func setConstraints() {
        addSubviews(image, bodyLabel)

        image.snp.makeConstraints { make in
            make.verticalEdges.leading.equalToSuperview()
            make.trailing.equalTo(snp.centerX).offset(-20)
        }

        bodyLabel.snp.makeConstraints { make in
            make.verticalEdges.trailing.equalToSuperview()
            make.leading.equalTo(image.snp.trailing).offset(10)
        }
    }
}
