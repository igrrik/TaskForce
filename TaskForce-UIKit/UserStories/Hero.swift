//
//  Hero.swift
//  TaskForce-UIKit
//
//  Created by Igor Kokoev on 13.02.2022.
//

import UIKit

extension UIImage {
    static let batman = UIImage(named: "batman")!
    static let superman = UIImage(named: "superman")!
}

struct Hero: Hashable {
    let identifier: UUID = .init()
    let name: String
    let image: UIImage
    let descriptionText: String = "Rick Jones has been Hulk's best bud since day one, but now he's more than a friend...he's a teammate! Transformed by a Gamma energy explosion, A-Bomb's thick, armored skin is just as strong and powerful as it is blue. And when he curls into action, he uses it like a giant bowling ball of destruction!Rick Jones has been Hulk's best bud since day one, but now he's more than a friend...he's a teammate! Transformed by a Gamma energy explosion, A-Bomb's thick, armored skin is just as strong and powerful as it is blue. And when he curls into action, he uses it like a giant bowling ball of destruction!Rick Jones has been Hulk's best bud since day one, but now he's more than a friend...he's a teammate! Transformed by a Gamma energy explosion, A-Bomb's thick, armored skin is just as strong and powerful as it is blue. And when he curls into action, he uses it like a giant bowling ball of destruction!Rick Jones has been Hulk's best bud since day one, but now he's more than a friend...he's a teammate! Transformed by a Gamma energy explosion, A-Bomb's thick, armored skin is just as strong and powerful as it is blue. And when he curls into action, he uses it like a giant bowling ball of destruction!Rick Jones has been Hulk's best bud since day one, but now he's more than a friend...he's a teammate! Transformed by a Gamma energy explosion, A-Bomb's thick, armored skin is just as strong and powerful as it is blue. And when he curls into action, he uses it like a giant bowling ball of destruction!Rick Jones has been Hulk's best bud since day one, but now he's more than a friend...he's a teammate! Transformed by a Gamma energy explosion, A-Bomb's thick, armored skin is just as strong and powerful as it is blue. And when he curls into action, he uses it like a giant bowling ball of destruction!he uses it like a giant bowling ball of destruction!"

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    static func == (lhs: Hero, rhs: Hero) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    static var spiderMan: Hero { Hero(name: "Spider-Man", image: .batman) }
    static var ironMan: Hero { Hero(name: "Iron Man", image: .superman) }
    static var blackPanther: Hero { Hero(name: "Black Panther", image: .batman) }
    static var hulk: Hero { Hero(name: "Hulk", image: .superman) }
    static var thor: Hero { Hero(name: "Thor", image: .batman) }
    static var hawkEye: Hero { Hero(name: "Hawkeye", image: .superman) }
    static var blackWidow: Hero { Hero(name: "Black Widow", image: .batman) }
    static var wolverine: Hero { Hero(name: "Wolverine", image: .superman) }
    static var dareDevil: Hero { Hero(name: "Daredevil", image: .batman) }
    static var magneto: Hero { Hero(name: "Magneto", image: .superman) }
}
