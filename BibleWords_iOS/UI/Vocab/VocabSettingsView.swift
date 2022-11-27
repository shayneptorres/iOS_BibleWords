//
//  VocabSettingsView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 11/26/22.
//

import SwiftUI

struct VocabSettingsView: View {
    var body: some View {
        List {
            NavigationLink(destination: {
                VocabNotificationsView()
            }, label: {
                Label("Notifications", systemImage: "bell")
            })
        }
        .navigationTitle("Settings")
    }
}

struct VocabSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VocabSettingsView()
        }
    }
}
