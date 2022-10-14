//
//  ListDetailView.swift
//  Bible_Words_iOS
//
//  Created by Shayne Torres on 10/13/22.
//

import SwiftUI
import Combine

class ListDetailViewModel: ObservableObject {
    @Published var list: WordList
    @Published var isBibleDataReady = false
    @Published var words: [Bible.WordInfo] = []
    private var subscribers: [AnyCancellable] = []
    
    init(list: WordList) {
        self.list = list
        
        API.main.dataReadyPublisher.sink { [weak self] isReady in
            if isReady {
                self?.buildWords()
            }
        }.store(in: &subscribers)
    }
    
    func buildWords() {
        guard words.isEmpty, API.main.dataReadyPublisher.value else {
            return
        }
        DispatchQueue.main.async {
            for range in self.list.rangesArr  {
                self.words.append(contentsOf: VocabListBuilder.buildVocabList(bookStart: range.bookStart.toInt,
                                                                  chapStart: range.chapStart.toInt,
                                                                  bookEnd: range.bookEnd.toInt,
                                                                  chapEnd: range.chapEnd.toInt,
                                                             occurrences: range.occurrences.toInt))
            }
            self.isBibleDataReady = true
        }
    }
}

struct ListDetailView: View {
    @Environment(\.managedObjectContext) var context
    @ObservedObject var viewModel: ListDetailViewModel
    @State var isBuilding = false
    
    var body: some View {
        List {
            if !viewModel.isBibleDataReady {
                HStack {
                    ProgressView()
                        .progressViewStyle(.automatic)
                        .padding(.trailing)
                    Text("Building words list...")
                }
            } else {
                Section {
                    ForEach(viewModel.words) { word in
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
        .navigationTitle(viewModel.list.defaultTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension ListDetailView {
    
}

//struct ListDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            ListDetailView(viewModel: .init(list: .init(context: PersistenceController.preview.container.viewContexts)))
//        }
//    }
//}
