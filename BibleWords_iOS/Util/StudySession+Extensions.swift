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

extension StudySession {
    var entriesArr: [StudySessionEntry] {
        return (entries?.allObjects ?? []) as! [StudySessionEntry]
    }
    
    var activityType: ActivityType {
        return ActivityType(rawValue: self.activityTypeInt) ?? .vocab
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
