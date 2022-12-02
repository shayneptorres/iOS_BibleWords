//
//  BibleWords_iOSApp.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/13/22.
//

import SwiftUI
import ActivityKit

@main
struct BibleWords_iOSApp: App {
    @Environment(\.scenePhase) var scenePhase
    
    let persistenceController = PersistenceController.shared

    
    var body: some Scene {
        WindowGroup {
            TabView {
                VocabListsView()
                .tabItem {
                    Label("Vocab", systemImage: "list.bullet.rectangle")
                }
                NavigationView {
                    ParsingListsView()
                }
                .navigationViewStyle(.stack)
                .tabItem {
                    Label("Parse", systemImage: "filemenu.and.selection")
                }
                NavigationView {
                    ConceptsView()
                }
                .navigationViewStyle(.stack)
                .tabItem {
                    Label("Learn", systemImage: "brain.head.profile")
                }
                NavigationView {
                    BibleReadingMainView()
                }
                .navigationViewStyle(.stack)
                .tabItem {
                    Label("Read", systemImage: "book")
                }
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .onAppear {
                if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                } else {
                    fetchData()
                }
                if #available(iOS 16.1, *) {
                    if !Activity<StudyAttributes>.activities.isEmpty {
                        for activity in Activity<StudyAttributes>.activities {
                            Task {
                                await activity.end(dismissalPolicy: .immediate)
                            }
                        }
                    }
                }
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    print("Active")
                } else if newPhase == .inactive {
                    print("Inactive")
                } else if newPhase == .background {
                    print("Background")
                    AppGroupManager.updateStats(persistenceController.container.viewContext)
                }
            }
        }
    }
    
    func fetchData() {
        Task {
            guard !API.main.coreDataReadyPublisher.value else { return }
            await API.main.fetchHebrewDict()
            await API.main.fetchHebrewBible()
            await API.main.fetchGreekDict()
            await API.main.fetchGreekBible()
            
            API.main.coreDataReadyPublisher.send(true)
        }
    }
}
