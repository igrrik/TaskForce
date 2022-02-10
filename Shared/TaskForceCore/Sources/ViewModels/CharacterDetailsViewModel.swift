//
//  CharacterDetailsViewModel.swift
//  
//
//  Created by Igor Kokoev on 07.02.2022.
//

import UIKit
import Combine

final class CharacterDetailsViewModel: ObservableObject {
    let name: String
    let description: String
    @Published private(set) var image: UIImage?
    @Published private(set) var isRecruited: Bool

    init(character: Character) {
        self.name = character.name
        self.description = character.description
        self.isRecruited = character.isRecruited
    }

    func toggleRecruitmentStatus() {

    }

    private func obtainImage() {
        
    }
}
