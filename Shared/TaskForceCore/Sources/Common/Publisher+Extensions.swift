//
//  Publisher+Extensions.swift
//  
//
//  Created by Igor Kokoev on 21.02.2022.
//

import Foundation
import Combine

extension Publisher {
    func sink(
        onValue: @escaping (Self.Output) -> Void,
        onError: @escaping (Self.Failure) -> Void,
        onFinish: (() -> Void)? = nil
    ) -> AnyCancellable {
        sink { completion in
            switch completion {
            case .finished:
                onFinish?()
            case .failure(let error):
                onError(error)
            }
        } receiveValue: { value in
            onValue(value)
        }
    }
}
