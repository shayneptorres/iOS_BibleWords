//
//  Widget-AppOnly.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/26/22.
//

import Foundation
import CoreData
import WidgetKit

extension AppGroupManager {
    static func updateStats(_ context: NSManagedObjectContext) {
        if UserDefaultKey.shouldRefreshWidgetTimeline.get(as: Bool.self) {
            AppGroupManager.clear()
            
            let sessionEntriesFetch = NSFetchRequest<StudySessionEntry>(entityName: "StudySessionEntry")
            sessionEntriesFetch.predicate = NSPredicate(format: "createdAt >= %@", Date.startOfToday as CVarArg)
            var entries: [StudySessionEntry] = []
            do {
                entries = try context.fetch(sessionEntriesFetch)
            } catch let err {
                print(err)
            }
            
            let vocabFetchRequest = NSFetchRequest<VocabWord>(entityName: "VocabWord")
            vocabFetchRequest.predicate = NSPredicate(format: "dueDate <= %@ && currentInterval > 0", Date().addingTimeInterval(Double(8.hours)) as CVarArg)
            var fetchedVocabWords: [VocabWord] = []
            do {
                fetchedVocabWords = try context.fetch(vocabFetchRequest)
            } catch let err {
                print(err)
            }
            
            fetchedVocabWords = fetchedVocabWords.filter { ($0.list?.count ?? 0) > 0 }
            let currentDate = Date()
            var stats: [Stat] = []
            var newCount = entries.filter { $0.studyTypeInt == 0 }.count
            var reviewedCount = entries.filter { $0.studyTypeInt == 1 }.count
            var parsedCount = entries.filter { $0.studyTypeInt == 2 }.count
            var dueCount = 0
            
            for i in 0 ... 64 {
                let entryDate = currentDate.addingTimeInterval(Double(15.minutes * i))
                if entryDate > Date.endOfToday {
                    newCount = 0
                    reviewedCount = 0
                    parsedCount = 0
                }
                dueCount = fetchedVocabWords.filter { $0.dueDate ?? Date() < entryDate }.count
                stats.append(.init(date: entryDate,
                                   reviewedCount: reviewedCount,
                                   parsedCount: parsedCount,
                                   newCount: newCount,
                                   dueCount: dueCount))
            }
            AppGroupManager.set(stats: stats)
            WidgetCenter.shared.reloadTimelines(ofKind: "TodayStatsWidget")
            UserDefaultKey.shouldRefreshWidgetTimeline.set(val: false)
        }
    }
}
