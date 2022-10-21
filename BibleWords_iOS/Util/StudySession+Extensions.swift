//
//  StudySession+Extensions.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/16/22.
//

import Foundation
import CoreData
import SwiftUI

enum SessionEntryType: Int16 {
    case newWord = 0
    case reviewedWord
    case parsing
}

enum SessionEntryAnswerType: Int16 {
    case wrong = 0
    case hard
    case good
    case easy
    
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

extension StudySession {
    var entriesArr: [StudySessionEntry] {
        return (entries?.allObjects ?? []) as! [StudySessionEntry]
    }
}

extension StudySessionEntry {
    static func new(context: NSManagedObjectContext, word: VocabWord?, answer: SessionEntryAnswerType, studyType: SessionEntryType? = nil) -> StudySessionEntry {
        let entry = StudySessionEntry(context: context)
        entry.id = UUID().uuidString
        entry.createdAt = Date()
        if studyType != nil {
            entry.studyTypeInt = studyType!.rawValue
        } else {
            entry.studyTypeInt = (word?.currentInterval ?? 0) == 0 ? SessionEntryType.newWord.rawValue : SessionEntryType.reviewedWord.rawValue
        }
        entry.answerTypeInt = answer.rawValue
        entry.word = word
        
        return entry
    }
    
    var answerType: SessionEntryAnswerType {
        return SessionEntryAnswerType(rawValue: self.answerTypeInt) ?? .wrong
    }
    
    var studyType: SessionEntryType {
        return SessionEntryType(rawValue: self.answerTypeInt) ?? .reviewedWord
    }
}
