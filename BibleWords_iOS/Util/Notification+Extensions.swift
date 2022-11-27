//
//  Notification+Extensions.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 11/26/22.
//

import Foundation
import CoreData
import UserNotifications

struct NotificationConstants {
    static let vocabDailyReminderPrefix = "vocab.daily."
    static let dueWordsReminderPrefix = "vocab.due."
}

struct DueWordAlertManager {
    static func updateDueWordNotifications(_ context: NSManagedObjectContext) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
            let pendingDueWordAlertIds = notifications
                .filter { $0.identifier.contains(NotificationConstants.dueWordsReminderPrefix) }
                .map { $0.identifier }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: pendingDueWordAlertIds)
        }
        
        let dueWordAlertFetchRequest = NSFetchRequest<DueWordAlert>(entityName: "DueWordAlert")
        var fetchedDueWordAlert: [DueWordAlert] = []
        do {
            fetchedDueWordAlert = try context.fetch(dueWordAlertFetchRequest)
        } catch let err {
            print(err)
        }
        
        let triggers = fetchedDueWordAlert.map { $0.triggerCount.toInt }.sorted()
        
        let vocabFetchRequest = NSFetchRequest<VocabWord>(entityName: "VocabWord")
        vocabFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \VocabWord.dueDate, ascending: true)]
        var fetchedVocabWords: [VocabWord] = []
        do {
            fetchedVocabWords = try context.fetch(vocabFetchRequest)
        } catch let err {
            print(err)
        }
        
        fetchedVocabWords = fetchedVocabWords.filter { ($0.list?.count ?? 0) > 0 }.sorted(by: { $0.dueDate ?? Date() < $1.dueDate ?? Date() })
        
        for triggerCount in triggers {
            guard
                fetchedVocabWords.count >= triggerCount,
                let date = fetchedVocabWords[triggerCount - 1].dueDate,
                date > Date()
            else { continue }
            
            let dailyReminderContent = UNMutableNotificationContent()
            dailyReminderContent.title = "Bible Words"
            dailyReminderContent.subtitle = "Due Words"
            dailyReminderContent.body = "You currently have \(triggerCount) words due! Tap here to review them."
            dailyReminderContent.categoryIdentifier = NotificationConstants.vocabDailyReminderPrefix.appending(UUID().uuidString)
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: date.timeIntervalSinceNow, repeats: false)
            let request = UNNotificationRequest(identifier: dailyReminderContent.categoryIdentifier, content: dailyReminderContent, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { (error) in
                if let error = error {
                    print("Error: Could not save daily reminder: \(error.localizedDescription)")
                } else {
                    print("Success: Saved notification!")
                }
            }
        }
    }
}
