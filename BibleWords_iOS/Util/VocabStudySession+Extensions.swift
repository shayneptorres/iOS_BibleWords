//
//  VocabStudySession+Extensions.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 11/23/22.
//

import Foundation
import SwiftUI
import CoreData

extension VocabStudySessionEntry {
    static func new(context: NSManagedObjectContext, word: VocabWord?, prevInterval: Int, interval: Int, newWord: Bool = false) -> VocabStudySessionEntry {
        let entry = VocabStudySessionEntry(context: context)
        entry.id = UUID().uuidString
        entry.createdAt = Date()
        entry.word = word
        entry.interval = interval.toInt32
        entry.prevInterval = prevInterval.toInt32
        entry.wasNewWord = newWord
        return entry
    }
    
    var prevIntervalStr: String {
        guard prevInterval >= 0, prevInterval <= VocabWord.defaultSRIntervals.count - 1 else { return "⚠️" }
        return VocabWord.defaultSRIntervals[prevInterval.toInt].toShortPrettyTime
    }
    
    var intervalStr: String {
        guard interval >= 0, interval <= VocabWord.defaultSRIntervals.count - 1 else { return "No valid interval data" }
        return VocabWord.defaultSRIntervals[interval.toInt].toShortPrettyTime
    }
}
