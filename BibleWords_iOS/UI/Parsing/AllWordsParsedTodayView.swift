//
//  AllWordsParsedTodayView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/20/22.
//

import SwiftUI

struct AllWordsParsedTodayView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \StudySessionEntry.createdAt, ascending: false)],
        predicate: NSPredicate(format: "createdAt >= %@ AND studyTypeInt == \(SessionEntryType.parsing.rawValue)", Date.startOfToday as CVarArg)
    ) var wordsParsedToday: FetchedResults<StudySessionEntry>
    
    var body: some View {
        List {
            HStack {
                Text("\(wordsParsedToday.count)")
                +
                Text(" words")
            }
            ForEach(wordsParsedToday) { entry in
                ParsingSessionEntryRow(entry: entry.bound())
            }
        }
        .navigationTitle("Words Parsed Today")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AllWordsParsedTodayView_Previews: PreviewProvider {
    static var previews: some View {
        AllWordsParsedTodayView()
    }
}
