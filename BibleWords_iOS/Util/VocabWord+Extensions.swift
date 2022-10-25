//
//  VocabWord+Extensions.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/14/22.
//

import Foundation
import CoreData
import SwiftUI

enum Language: Int16 {
    case hebrew = 0
    case aramaic
    case greek
    case all
    
    var title: String {
        switch self {
        case .hebrew: return "Hebrew"
        case .greek: return "Greek"
        case .aramaic: return "Aramaic"
        case .all: return "All"
        }
    }
    
    var filters: [Language] {
        return [.all, .hebrew, .greek]
    }
    
    var meduimBibleFont: Font {
        switch self {
        case .hebrew: return .bible40
        case .greek: return .bible24
        case .aramaic: return .bible40
        case .all: return .bible40
        }
    }
    
    var largeBibleFont: Font {
        switch self {
        case .hebrew: return .bible40
        case .greek: return .bible32
        case .aramaic: return .bible40
        case .all: return .bible40
        }
    }
    
    var xlargeBibleFont: Font {
        switch self {
        case .hebrew: return .bible100
        case .greek: return .bible72
        case .aramaic: return .bible100
        case .all: return .bible100
        }
    }
}


extension VocabWord: Bindable {
    
    var lemma: String {
        if (customLemma ?? "").isEmpty {
            return wordInfo.lemma
        } else {
            return customLemma ?? ""
        }
    }
    
    var definition: String {
        if (customDefinition ?? "").isEmpty {
            return wordInfo.definition
        } else {
            return customDefinition ?? ""
        }
    }
    
    var wordInfo: Bible.WordInfo {
        if Language(rawValue: self.lang) == .greek {
            return Bible.main.greekLexicon.word(for: self.id ?? "", source: self.sourceId ?? "") ?? .init([:])
        } else {
            return Bible.main.hebrewLexicon.word(for: self.id ?? "", source: self.sourceId ?? "") ?? .init([:])
        }
    }
    /// An array of the different Spaced Repitition intervals, in seconds
    static let defaultSRIntervals: [Int] = [0,
                                            1.minutes,
                                            2.minutes,
                                            5.minutes,
                                            15.minutes,
                                            30.minutes,
                                            1.hours,
                                            3.hours,
                                            6.hours,
                                            1.days,
                                            3.days,
                                            7.days,
                                            14.days,
                                            1.months,
                                            2.months,
                                            5.months,
                                            8.months,
                                            1.years,
                                            2.years,
                                            3.years,
                                            5.years,
                                            10.years]
    
    var sessionEntriesArr: [StudySessionEntry] {
        return (sessionEntries?.allObjects ?? []) as! [StudySessionEntry]
    }
}

extension VocabWord {
    convenience init(context: NSManagedObjectContext, wordInfo: Bible.WordInfo) {
        self.init(context: context)
        self.id = wordInfo.id
        self.customLemma = wordInfo.lemma
        self.customDefinition = wordInfo.definition
        self.createdAt = Date()
        self.currentInterval = 0
        self.lang = wordInfo.language.rawValue
        self.dueDate = Date()
    }
    
    var isDue: Bool {
        return self.dueDate ?? Date() <= Date() && self.currentInterval > 0
    }
}

extension Bible.WordInfo {
    func isNewVocab(context: NSManagedObjectContext) -> Bool {
        return self.vocabWord(context: context) == nil || self.vocabWord(context: context)?.currentInterval == 0
    }
}
