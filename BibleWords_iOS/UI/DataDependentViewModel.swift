//
//  DataDependentViewModel.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/17/22.
//

import Foundation
import Combine

class DataDependentViewModel: ObservableObject {
    @Published var isBuilding = true
    let id = UUID().uuidString
    private var subscribers: [AnyCancellable] = []
    
    init() {
        Task {
            API.main.coreDataReadyPublisher.sink { [weak self] isReady in
                if isReady {
                    self?.isBuilding = false
                }
            }.store(in: &self.subscribers)
        }
    }
}
