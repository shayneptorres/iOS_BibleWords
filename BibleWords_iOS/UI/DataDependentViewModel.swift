//
//  DataDependentViewModel.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/17/22.
//

import Foundation
import Combine
import SwiftUI

class DataDependentViewModel: ObservableObject {
    @Published var isBuilding = true
    @Published var animationRotationAngle: CGFloat = 0.0
    @Published var timer: Publishers.Autoconnect<Timer.TimerPublisher>? = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let id = UUID().uuidString
    private var subscribers: [AnyCancellable] = []
    
    init() {
        Task {
            API.main.coreDataReadyPublisher.sink { [weak self] isReady in
                if isReady {
                    withAnimation {
                        self?.timer?.upstream.connect().cancel()
                        self?.timer = nil
                        self?.isBuilding = false
                    }
                }
            }.store(in: &self.subscribers)
        }
        
        timer?.sink { [weak self] _ in
            self?.animationRotationAngle += 360
        }.store(in: &subscribers)
    }
}
