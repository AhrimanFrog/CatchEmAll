import UIKit
import SnapKit

class InfoCell: UITableViewCell, ReuseIdentifiable {
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setConstraints()
        configure()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = ""
        bodyLabel.text = ""
    }

    func setText(title: String, body: String) {
        titleLabel.text = title
        bodyLabel.text = body
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        titleLabel.font = .lato(ofSize: 18, weight: .bold)
        bodyLabel.font = .lato(ofSize: 18)
        selectionStyle = .none
    }

    private func setConstraints() {
        addSubviews(titleLabel, bodyLabel)

        titleLabel.snp.makeConstraints { make in
            make.verticalEdges.leading.equalToSuperview()
            make.trailing.equalTo(snp.centerX).offset(-20)
        }

        bodyLabel.snp.makeConstraints { make in
            make.verticalEdges.trailing.equalToSuperview()
            make.leading.equalTo(titleLabel.snp.trailing).offset(10)
        }
    }
}
