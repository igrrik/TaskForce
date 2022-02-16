//
//  RecruitButton.swift
//  TaskForce-UIKit
//
//  Created by Igor Kokoev on 15.02.2022.
//

import UIKit

final class RecruitButton: UIButton {
    enum Style {
        case standard
        case outlined
    }

    var style: Style {
        didSet {
            updateStyle(style)
        }
    }

    override var isHighlighted: Bool {
        didSet {
            updateColorConfiguration()
        }
    }

    init(frame: CGRect, style: Style) {
        self.style = style
        super.init(frame: frame)
        configureUI(style: style)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI(style: Style) {
        layer.cornerRadius = Constants.cornerRadius
        titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel?.textColor = .white
        updateStyle(style)
    }

    private func updateStyle(_ style: Style) {
        resetStyle()

        switch style {
        case .standard:
            layer.shadowRadius = Constants.shadowRadius
            layer.shadowOffset = Constants.shadowOffset
            layer.shadowOpacity = Constants.shadowOpacity
        case .outlined:
            layer.borderWidth = Constants.borderWidth
        }

        updateColorConfiguration()
    }

    private func resetStyle() {
        backgroundColor = nil
        layer.shadowColor = nil
        layer.shadowRadius = 0
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0
        layer.borderWidth = 0
        layer.borderColor = nil
    }

    private func updateColorConfiguration() {
        let color = isHighlighted ? Constants.highlightedColor : Constants.defaultColor

        switch style {
        case .standard:
            backgroundColor = color
            layer.shadowColor = color.cgColor
        case .outlined:
            layer.borderColor = color.cgColor
        }
    }
}

private enum Constants {
    static let cornerRadius: CGFloat = 8
    static let borderWidth: CGFloat = 3
    static let shadowRadius: CGFloat = 16
    static let shadowOffset = CGSize(width: 0, height: 4)
    static let shadowOpacity: Float = 0.5
    static let defaultColor: UIColor = Asset.Colors.marvelRedLight.color
    static let highlightedColor: UIColor = Asset.Colors.marvelRedDark.color
}
