//
//  VocabWordDifficultyStatsView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/24/22.
//

import SwiftUI

//struct VocabWordDifficultyStatsView: View {
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \VocabWord.createdAt, ascending: false)]
//    ) var words: FetchedResults<VocabWord>
//    
//    @Environment(\.managedObjectContext) var context
//    @Environment(\.presentationMode) var presentationMode
//    
//    @State var selectedAnswerType: SessionEntryAnswerType = .easy
//    
//    var displayWords: [VocabWord] {
//        var dict = [VocabWord:[StudySessionEntry]]()
//        
//        words.forEach {
//            dict[$0] = $0.sessionEntriesArr.filter { $0.answerType == selectedAnswerType }
//        }
//        
//        return Array(Array(dict.keys).sorted { dict[$0]?.count ?? 0 > dict[$1]?.count ?? 0 }.prefix(upTo: 10))
//    }
//    
//    var body: some View {
//        List {
//            Picker("Answer Type", selection: $selectedAnswerType) {
//                ForEach(SessionEntryAnswerType.allCases, id: \.rawValue) { answerType in
//                    Text(answerType.title).tag(answerType)
//                }
//            }
//            ForEach(displayWords) { word in
//                HStack {
//                    WordInfoRow(wordInfo: word.wordInfo.bound())
//                    Spacer()
//                    Text("\(word.sessionEntriesArr.filter { $0.answerType == selectedAnswerType }.count)")
//                }
//            }
//        }
//    }
//}
//
//struct VocabWordDifficultyStatsView_Previews: PreviewProvider {
//    static var previews: some View {
//        VocabWordDifficultyStatsView()
//    }
//}
