//
//  CharactersListTitleView.swift
//  TaskForce-UIKit
//
//  Created by Igor Kokoev on 13.02.2022.
//

import UIKit

final class CharactersListTitleView: UICollectionReusableView {

    typealias HeaderRegistration = UICollectionView.SupplementaryRegistration<CharactersListTitleView>

    static var kind: String { String(describing: self) }

    private(set) lazy var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureLayout()
    }

    static func headerRegistration(handler: @escaping HeaderRegistration.Handler) -> HeaderRegistration {
        .init(elementKind: kind, handler: handler)
    }

    private func configureLayout() {
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
