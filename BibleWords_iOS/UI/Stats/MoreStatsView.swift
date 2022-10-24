//
//  MoreStatsView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/23/22.
//

import SwiftUI

struct MoreStatsView: View {
    enum SettingPath: Hashable {
        case vocabInterval
        case answerStats
    }
    
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(value: SettingPath.vocabInterval) {
                        Text("Vocab Word Progress")
                    }
                    NavigationLink(value: SettingPath.answerStats) {
                        Text("Vocab Word Answer Stats")
                    }
                } header: {
                    Text("Vocab Word Stats")
                }
            }
            .toolbar {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Dismiss")
                        .bold()
                })
            }
            .navigationTitle("App Statistics")
            .navigationDestination(for: SettingPath.self) { path in
                switch path {
                case .vocabInterval:
                    VocabWordIntervalStatsView()
                case .answerStats:
                    VocabWordDifficultyStatsView()
                }
            }
        }
    }
}

struct MoreStatsView_Previews: PreviewProvider {
    static var previews: some View {
        MoreStatsView()
    }
}
