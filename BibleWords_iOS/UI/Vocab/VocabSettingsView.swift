//
//  VocabSettingsView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 11/26/22.
//

import SwiftUI

struct VocabSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        List {
            NavigationLink(destination: {
                VocabNotificationsView()
            }, label: {
                Label("Notifications", systemImage: "bell")
            })
        }
        .navigationTitle("Settings")
        .toolbar {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Dismiss")
                    .bold()
            })
        }
    }
}

struct VocabSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VocabSettingsView()
        }
    }
}
