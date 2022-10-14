//
//  BibleWords_iOSApp.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/13/22.
//

import SwiftUI

@main
struct BibleWords_iOSApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MainView()
            }
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
