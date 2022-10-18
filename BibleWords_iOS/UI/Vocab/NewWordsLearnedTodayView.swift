//
//  NewWordsLearnedTodayView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/16/22.
//

import SwiftUI
import Combine

struct NewWordsLearnedTodayView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \StudySessionEntry.createdAt, ascending: false)],
        predicate: NSPredicate(format: "createdAt >= %@ AND studyTypeInt == 0", Date.startOfToday as CVarArg)
    ) var newWordEntries: FetchedResults<StudySessionEntry>
    @ObservedObject var viewModel = DataDependentViewModel()
    
    var body: some View {
        List {
            if viewModel.isBuilding {
                HStack {
                    ProgressView()
                        .progressViewStyle(.automatic)
                        .padding(.trailing)
                    Text("Building bible words data...")
                }
            } else {
                ForEach(newWordEntries.compactMap { $0.word?.wordInfo }) { wordInfo in
                    WordInfoRow(wordInfo: wordInfo.bound())
                }
            }
        }.navigationTitle("New Words Today")
    }
}

struct NewWordsLearnedTodayView_Previews: PreviewProvider {
    static var previews: some View {
        NewWordsLearnedTodayView()
    }
}
