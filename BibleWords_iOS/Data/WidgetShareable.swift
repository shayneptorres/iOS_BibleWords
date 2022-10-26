//
//  WidgetShareable.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/21/22.
//

import Foundation
import WidgetKit

struct Stat: Codable {
    let date: Date
    let reviewedCount: Int
    let parsedCount: Int
    let newCount: Int
    let dueCount: Int
}

struct TodayStatsEntry: TimelineEntry {
    let date: Date
    let reviewedCount: Int
    let parsedCount: Int
    let newCount: Int
    let dueCount: Int
}

extension Stat {
    var toEntry: TodayStatsEntry {
        return TodayStatsEntry(date: self.date,
                               reviewedCount: self.reviewedCount,
                               parsedCount: self.parsedCount,
                               newCount: self.newCount,
                               dueCount: self.dueCount)
    }
}

struct AppGroupManager {
    static let defaults = UserDefaults(suiteName: "group.com.shayneptorres.BibleWords")
    
    static func clear() {
        defaults?.set([], forKey: "stats")
    }
    
    static func set(stats: [Stat]) {
        let statData = try! JSONEncoder().encode(stats)
        defaults?.set(statData, forKey: "stats")
    }
    
    static func getStats() -> [Stat] {
        var stats: [Stat] = []
        /* Reading the encoded data from your shared App Group container storage */
        if let encodedData = AppGroupManager.defaults?.object(forKey: "stats") as? Data {
            /* Decoding it using JSONDecoder*/
            let statsDecoded = try? JSONDecoder().decode([Stat].self, from: encodedData)
            stats = statsDecoded ?? []
        }
        
        return stats
    }
    
}
