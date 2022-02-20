//
//  SquadManager.swift
//  
//
//  Created by Igor Kokoev on 17.02.2022.
//

import Foundation
import Combine

public protocol SquadManager {
    func observeSquadMembers() -> AnyPublisher<Set<Character>, Never>
    func recruit(_ character: Character)
    func fire(_ character: Character)
}
