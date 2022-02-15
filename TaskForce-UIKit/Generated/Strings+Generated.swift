// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// No Description
  internal static let characterDetailsNoDescription = L10n.tr("Localizable", "character_details_no_description")
  /// 🔥  Fire from Squad
  internal static let characterDetailsRecruitButtonFireTitle = L10n.tr("Localizable", "character_details_recruit_button_fire_title")
  /// 💪  Recruit to Squad
  internal static let characterDetailsRecruitButtonRecruitTitle = L10n.tr("Localizable", "character_details_recruit_button_recruit_title")
  /// My Squad
  internal static let charactersListSquadHeaderTitle = L10n.tr("Localizable", "characters_list_squad_header_title")
  /// Error
  internal static let error = L10n.tr("Localizable", "error")
  /// OK
  internal static let ok = L10n.tr("Localizable", "ok")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
