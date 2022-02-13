//
//  CharacterDetailsViewModel.swift
//  
//
//  Created by Igor Kokoev on 07.02.2022.
//

import UIKit
import Combine

public final class CharacterDetailsViewModel: ObservableObject {
    let name: String
    let info: String
    @Published private(set) var image: UIImage?
    @Published private(set) var isRecruited: Bool

    init(character: Character) {
        self.name = character.name
        self.info = character.info
        self.isRecruited = character.isRecruited
    }

    public func toggleRecruitmentStatus() {

    }

    private func obtainImage() {
        
    }
}
