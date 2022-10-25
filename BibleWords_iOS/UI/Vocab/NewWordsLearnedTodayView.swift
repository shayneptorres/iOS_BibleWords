//
//  NewWordsLearnedTodayView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/16/22.
//

import SwiftUI
import Combine

struct WordsSeenTodayView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \StudySessionEntry.createdAt, ascending: false)],
        predicate: NSPredicate(format: "createdAt >= %@", Date.startOfToday as CVarArg)
    ) var wordEntries: FetchedResults<StudySessionEntry>
    
    @ObservedObject var viewModel = DataDependentViewModel()
    var entryType = SessionEntryType.newWord
    
    var words: [Bible.WordInfo] {
        switch entryType {
        case .newWord:
            return wordEntries.filter { $0.studyTypeInt == 0 }.compactMap { $0.word?.wordInfo }
        case .reviewedWord:
            return wordEntries.filter { $0.studyTypeInt == 1 }.compactMap { $0.word?.wordInfo }
        case .parsing:
            return []
        }
    }
    
    var title: String {
        switch entryType {
        case .newWord:
            return "New Words Seen Today"
        case .reviewedWord:
            return "Words Reviewed Today"
        case .parsing:
            return "Words Parsed Today"
        }
    }
    
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
                if [SessionEntryType.newWord, .reviewedWord].contains(entryType) {
                    ForEach(words) { word in
                        NavigationLink(value: AppPath.wordInfo(word)) {
                            WordInfoRow(wordInfo: word.bound())
                        }
                    }
                } else {
                    ForEach(wordEntries.filter { $0.studyTypeInt == 2 }) { entry in
                        ParsingSessionEntryRow(entry: entry.bound())
                    }
                }
            }
        }.navigationTitle(title)
    }
}

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
