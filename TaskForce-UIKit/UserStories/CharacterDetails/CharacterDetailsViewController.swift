//
//  CharacterDetailsViewController.swift
//  TaskForce-UIKit
//
//  Created by Igor Kokoev on 03.02.2022.
//

import UIKit
import Combine

final class CharacterDetailsViewController: UIViewController {
    private let viewModel: CharacterDetailsViewModel
    private var cancellableBag = Set<AnyCancellable>()
    private lazy var scrollView = UIScrollView()
    private lazy var imageView = UIImageView()
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.name
        label.numberOfLines = 2
        label.textColor = .white
        label.font = .systemFont(ofSize: 34, weight: .bold)
        return label
    }()
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.info
        label.textColor = .white
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17, weight: .regular)
        return label
    }()
    private lazy var recruitButton: RecruitButton = {
        let button = RecruitButton(frame: .zero, style: .standard)
        button.addTarget(self, action: #selector(didTapRecruitButton), for: .touchUpInside)
        return button
    }()

    init(viewModel: CharacterDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Asset.Colors.marvelBackground.color
        configureLayout()
        configureBindings()
    }

    private func configureBindings() {
        viewModel.$image
            .assign(to: \.image, on: imageView)
            .store(in: &cancellableBag)

        viewModel.$isRecruited
            .map(String.recruitButtonTitle(isRecruited:))
            .sink(receiveValue: { [weak self] text in
                self?.recruitButton.setTitle(text, for: .normal)
            })
            .store(in: &cancellableBag)

        viewModel.$isRecruited
            .map(RecruitButton.Style.styleForRecruitmentStatus)
            .assign(to: \.style, on: recruitButton)
            .store(in: &cancellableBag)
    }

    private func configureLayout() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        let frameGuide = scrollView.frameLayoutGuide
        NSLayoutConstraint.activate([
            frameGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            frameGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            frameGuide.topAnchor.constraint(equalTo: view.topAnchor),
            frameGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        let contentGuide = scrollView.contentLayoutGuide
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: contentGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: contentGuide.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: contentGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: contentGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: frameGuide.widthAnchor)
        ])

        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        ])

        NSLayoutConstraint.activate([
            recruitButton.heightAnchor.constraint(equalToConstant: 48)
        ])

        let stackView = UIStackView(arrangedSubviews: [nameLabel, recruitButton, descriptionLabel])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 16.0
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 24),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])

        descriptionLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 200), for: .vertical)
    }

    @objc private func didTapRecruitButton() {
        viewModel.toggleRecruitmentStatus()
    }
}

private extension String {
    static func recruitButtonTitle(isRecruited: Bool) -> String {
        isRecruited ?  L10n.characterDetailsRecruitButtonFireTitle : L10n.characterDetailsRecruitButtonRecruitTitle
    }
}

private extension RecruitButton.Style {
    static func styleForRecruitmentStatus(_ isRecruited: Bool) -> Self {
        isRecruited ? .outlined : .standard
    }
}
