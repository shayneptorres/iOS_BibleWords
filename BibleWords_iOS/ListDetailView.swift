//
//  ListDetailView.swift
//  Bible_Words_iOS
//
//  Created by Shayne Torres on 10/13/22.
//

import SwiftUI

struct ListDetailView: View {
    @Environment(\.managedObjectContext) var context
    @Binding var list: WordList
    @State var words: [Bible.WordInfo] = []
    @State var isBuilding = false
    
    var body: some View {
        List {
            if isBuilding {
                Text("Building words list...")
            } else {
                Section {
                    ForEach(words) { word in
                        VStack(alignment: .leading) {
                            Text(word.lemma)
                                .font(.bible24)
                            Text(word.definition)
                                .font(.subheadline)
                        }
                    }
                }
            }
        }
        .navigationTitle(list.defaultTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            buildWords()
        }
    }
}

extension ListDetailView {
    func buildWords() {
        guard words.isEmpty else {
            return
        }
        isBuilding = true
        DispatchQueue.global().async {
            for range in list.rangesArr  {
                words = VocabListBuilder.buildVocabList(bookStart: range.bookStart.toInt,
                                                     chapStart: range.chapStart.toInt,
                                                     bookEnd: range.bookEnd.toInt,
                                                     chapEnd: range.chapEnd.toInt,
                                                occurrences: range.occurrences.toInt)
            }
            isBuilding = false
        }
    }
}

struct ListDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ListDetailView(list: .constant(.init(context: PersistenceController.preview.container.viewContext)))
        }
    }
}
