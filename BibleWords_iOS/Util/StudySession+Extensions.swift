//
//  StudySession+Extensions.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/16/22.
//

import Foundation
import CoreData

enum SessionEntryType: Int16 {
    case newWord = 0
    case reviewedWord
}

enum SessionEntryAnswerType: Int16 {
    case wrong = 0
    case hard
    case good
    case easy
}

extension StudySession {
    
}

extension StudySessionEntry {
    static func new(context: NSManagedObjectContext, word: VocabWord?, answer: SessionEntryAnswerType) -> StudySessionEntry {
        let entry = StudySessionEntry(context: context)
        entry.id = UUID().uuidString
        entry.createdAt = Date()
        entry.studyTypeInt = (word?.currentInterval ?? 0) == 0 ? SessionEntryType.newWord.rawValue : SessionEntryType.reviewedWord.rawValue
        entry.answerTypeInt = answer.rawValue
        entry.word = word
        
        return entry
    }
}
