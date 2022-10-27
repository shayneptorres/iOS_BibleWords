//
//  StudySessionAnswerType.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/26/22.
//

import Foundation
import SwiftUI

enum SessionEntryAnswerType: Int16, CaseIterable {
    case wrong = 0
    case hard
    case good
    case easy
    
    var title: String {
        switch self {
        case .wrong:
            return "Wrong"
        case .hard:
            return "Hard"
        case .good:
            return "Good"
        case .easy:
            return "Easy"
        }
    }
    
    var rowImage: some View {
        switch self {
        case .wrong:
            return Image(systemName: "xmark.octagon.fill").foregroundColor(.red)
        case .hard:
            return Image(systemName: "tortoise.fill").foregroundColor(.orange)
        case .good:
            return Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
        case .easy:
            return Image(systemName: "hare.fill").foregroundColor(.accentColor)
        }
    }
    
    var buttonImage: some View {
        switch self {
        case .wrong:
            return Image(systemName: "xmark.octagon").foregroundColor(.white)
        case .hard:
            return Image(systemName: "tortoise").foregroundColor(.white)
        case .good:
            return Image(systemName: "checkmark.circle").foregroundColor(.white)
        case .easy:
            return Image(systemName: "hare").foregroundColor(.white)
        }
    }
    
    var color: Color {
        switch self {
        case .wrong:
            return .red
        case .hard:
            return .orange
        case .good:
            return .green
        case .easy:
            return .accentColor
        }
    }
}
