//
//  WordOccurrencesListView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 12/2/22.
//

import SwiftUI

struct WordOccurrencesListView: View {
    var wordInfo: Bible.WordInfo
    
    var body: some View {
        List {
            Section {
                WordOccurrenceBarChartView(occurrences: .constant(wordInfo.instances))
                    .frame(height: 300)
            }
            ForEach(wordInfo.bibleBookOccurenceGroups) { bookGroup in
                BibleGroupOccurrenceListSection(group: bookGroup)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(wordInfo.lemma)
                    .font(wordInfo.language.meduimBibleFont)
            }
        }
    }
    
    struct BibleGroupOccurrenceListSection: View {
        let group: Bible.BibleBookOccurrenceGroup
        @State var visible = true
        
        var body: some View {
            Section {
                if visible {
                    ForEach(group.occurrences) { instance in
                        NavigationLink(destination: {
                                WordInstancePassageDetailsView(word: instance.wordInfo, instance: instance)
                        }) {
                            WordInstancePassageListRow(instance: instance)
                        }
                    }
                }
            } header: {
                HStack {
                    Text("\(group.book.title) (\(group.occurrences.count) occurrences)")
                    Spacer()
                    Button(action: {
                        withAnimation {
                            visible.toggle()
                        }
                    }, label: {
                        Image(systemName: "chevron.up")
                            .rotationEffect(visible ? Angle(degrees: 0) : Angle(degrees: 180))
                    })
                }
            }
        }
    }
}

//struct WordOccurrencesListView_Previews: PreviewProvider {
//    static var previews: some View {
//        WordOccurrencesListView(occurrences: .constant([]))
//    }
//}
