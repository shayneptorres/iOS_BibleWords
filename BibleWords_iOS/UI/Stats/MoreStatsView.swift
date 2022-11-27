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
        NavigationView {
            List {
                Section {
                    NavigationLink(destination: {
                        VocabWordIntervalStatsView()
                    }, label: {
                        Text("Vocab Word Progress")
                    })
                    NavigationLink(destination: {
                        StudyActivityView()
                    }, label: {
                        Text("Study Activity")
                    })
//                    NavigationLink(destination: {
//                        VocabWordDifficultyStatsView()
//                    }, label: {
//                        Text("Vocab Word Answer Stats")
//                    })
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
        }
    }
}

struct MoreStatsView_Previews: PreviewProvider {
    static var previews: some View {
        MoreStatsView()
    }
}
