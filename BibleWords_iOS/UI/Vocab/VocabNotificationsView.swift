//
//  VocabNotificationsView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 11/26/22.
//

import SwiftUI
import UserNotifications

struct VocabNotificationsView: View {
    struct DailyReminder: Identifiable {
        let id: String
        let dateComponents: DateComponents
        var title: String {
            let hour = (dateComponents.hour ?? 0) <= 12 ? (dateComponents.hour ?? 0) : ((dateComponents.hour ?? 0) - 12)
            let min = dateComponents.minute ?? 0
            let ampm = (dateComponents.hour ?? 0) >= 12 ? "pm" : "am"
            return "Reminder at \(hour):\(min < 10 ? "0\(min)" : "\(min)") \(ampm)"
        }
    }
    
    @Environment(\.managedObjectContext) var context
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \DueWordAlert.createdAt, ascending: false)]
    ) var dueWordAlerts: FetchedResults<DueWordAlert>
    
    // MARK: State Variables
    @State var notificationAuthorization: UNAuthorizationStatus = .notDetermined
    @State var showReminderForm = false
    @State var showDueWordAlertForm = false
    
    @State var reminderFormDate = Date()
    @State var dueWordAlertFormCountStr = ""
    
    @State var dailyReminders: [DailyReminder] = []
    
    var body: some View {
        List {
            if notificationAuthorization == .notDetermined {
                Text("It looks like you have not yet allowed us to send you notifications. To receive them, tap the button below and accept the prompt.")
                Button(action: {
                    requestAuthorization()
                }, label: {
                    Label("Allow Notifications", systemImage: "bell.fill")
                })
            } else if notificationAuthorization == .denied {
                Text("It looks like you have not have notification permissions turned on. To receive them, tap the button below to be directed to your phone's settings page and allow them there.")
                Button(action: {
                    requestAuthorization()
                }, label: {
                    Label("Allow Notifications", systemImage: "bell.fill")
                })
            } else if notificationAuthorization == .authorized {
                Section {
                    ForEach(dailyReminders) { dailyReminder in
                        Text(dailyReminder.title)
                            .swipeActions {
                                Button(action: {
                                    delete(reminder: dailyReminder)
                                }, label: {
                                    Text("Delete")
                                })
                                .tint(.red)
                            }
                    }
                    Button(action: {
                        reminderFormDate = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()
                        showReminderForm = true
                    }, label: {
                        Label("Add Reminder", systemImage: "alarm")
                    })
                } header: {
                    Text("Daily Reminders")
                } footer: {
                    Text("Daily reminders are a helpful way to stay on track with your vocab. We all need some reminders in life.")
                }
                
//                Section {
//                    ForEach(dueWordAlerts) { dueWordAlert in
//                        Text("Alert at \(dueWordAlert.triggerCount) due words")
//                            .swipeActions {
//                                Button(action: {
//                                    delete(dueWordAlert: dueWordAlert)
//                                }, label: {
//                                    Text("Delete")
//                                })
//                                .tint(.red)
//                            }
//                    }
//                    Button(action: {
//                        showDueWordAlertForm = true
//                    }, label: {
//                        Label("Add Alert", systemImage: "bell")
//                    })
//                } header: {
//                    Text("Due Word Alerts")
//                } footer: {
//                    Text("Your due words can add up quick. Add Due Word Alerts to let you know when you have a certain amount of due words to review")
//                }
            }
        }
        .onAppear {
            UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
                print(notifications)
                print(notifications.count)
                print("")
            }
            getSetNotificationAuth()
            getPendingNotifications()
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showReminderForm, content: {
            NavigationView {
                Form {
                    DatePicker("Send Reminder at:", selection: $reminderFormDate, displayedComponents: [.hourAndMinute])
                }
                .navigationTitle("Add Daily Reminder")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showReminderForm = false
                        }, label: {
                            Text("Dismiss")
                        })
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            onSaveReminder()
                        }, label: {
                            Text("Save")
                                .bold()
                        })
                    }
                }
            }
        })
        .sheet(isPresented: $showDueWordAlertForm, content: {
            NavigationView {
                Form {
                    Section {
                        TextField("Due Word Count", text: $dueWordAlertFormCountStr)
                            .keyboardType(.numberPad)
                    } footer: {
                        Text("The app will send a notification when you have this many words due")
                    }
                }
                .navigationTitle("Add Due Word Alert")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showDueWordAlertForm = false
                        }, label: {
                            Text("Dismiss")
                        })
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            onSaveDueWordAlert()
                            showDueWordAlertForm = false
                        }, label: {
                            Text("Save")
                                .bold()
                        })
                    }
                }
            }
        })
    }
}

extension VocabNotificationsView {
    func getSetNotificationAuth() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            self.notificationAuthorization = settings.authorizationStatus
        }
    }
    
    func getPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { pendingNotifications in
            self.dailyReminders = pendingNotifications.filter {
                $0.identifier.contains(NotificationConstants.vocabDailyReminderPrefix)
            }
            .compactMap {
                guard let trigger = $0.trigger as? UNCalendarNotificationTrigger else { return nil }
                return DailyReminder(id: $0.identifier, dateComponents: trigger.dateComponents)
            }
        }
    }
    
    func delete(reminder: DailyReminder) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminder.id])
        getPendingNotifications()
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                getSetNotificationAuth()
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func onSaveReminder() {
        let dailyReminderContent = UNMutableNotificationContent()
        dailyReminderContent.title = "Bible Words"
        dailyReminderContent.subtitle = "Study Vocab Reminder"
        dailyReminderContent.body = "Don't forget to study your Bible Vocab Words today. Tap this notification to get started."
        dailyReminderContent.categoryIdentifier = NotificationConstants.vocabDailyReminderPrefix.appending(UUID().uuidString)
        let hour = Calendar.current.component(.hour, from: reminderFormDate)
        let min = Calendar.current.component(.minute, from: reminderFormDate)
        let dateComponents = DateComponents(hour: hour, minute: min)
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true)
        let request = UNNotificationRequest(identifier: dailyReminderContent.categoryIdentifier, content: dailyReminderContent, trigger: trigger)
         
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error: Could not save daily reminder: \(error.localizedDescription)")
            } else {
                getPendingNotifications()
                showReminderForm = false
            }
        }
    }
    
    func onSaveDueWordAlert() {
        CoreDataManager.transaction(context: context) {
            let dueWordAlert = DueWordAlert(context: context)
            dueWordAlert.id = UUID().uuidString
            dueWordAlert.createdAt = Date()
            dueWordAlert.triggerCount = Int32(dueWordAlertFormCountStr) ?? 0
        }
    }
    
    func delete(dueWordAlert: DueWordAlert) {
        CoreDataManager.transaction(context: context) {
            context.delete(dueWordAlert)
        }
    }
}

struct VocabNotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VocabNotificationsView()
        }
    }
}
