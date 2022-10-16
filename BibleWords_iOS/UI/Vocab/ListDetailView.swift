//
//  ListDetailView.swift
//  Bible_Words_iOS
//
//  Created by Shayne Torres on 10/13/22.
//

import SwiftUI
import Combine

class ListDetailViewModel: ObservableObject, Equatable {
    @Published var list: VocabWordList
    @Published var isBuilding = true
    @Published var words: [Bible.WordInfo] = []
    var wordsAreReady = CurrentValueSubject<[Bible.WordInfo], Never>([])
    private var subscribers: [AnyCancellable] = []
    
    init(list: VocabWordList) {
        self.list = list
        
        Task {
            if list.sourceType == .app {
                API.main.coreDataReadyPublisher.sink { [weak self] isReady in
                    if isReady {
                        self?.buildBibleWords()
                    }
                }.store(in: &self.subscribers)
            } else {
                API.main.builtTextbooks.sink { [weak self] builtTextbooks in
                    if builtTextbooks.contains(.garretHebrew) {
                        self?.buildTextbookWords()
                    } else {
                        Task {
                            await API.main.fetchGarretHebrew()
                        }
                    }
                }.store(in: &self.subscribers)
            }
        }
        
        wordsAreReady.sink { builtWords in
            DispatchQueue.main.async {
                if !builtWords.isEmpty {
                    self.words = builtWords
                    self.isBuilding = false
                }
            }
        }.store(in: &subscribers)
    }
    
    static func == (lhs: ListDetailViewModel, rhs: ListDetailViewModel) -> Bool {
        return (lhs.list.id ?? "") == (rhs.list.id ?? "")
    }
    
    func buildBibleWords() {
        for range in self.list.rangesArr  {
            let w = VocabListBuilder.buildVocabList(bookStart: range.bookStart.toInt,
                                                    chapStart: range.chapStart.toInt,
                                                    bookEnd: range.bookEnd.toInt,
                                                    chapEnd: range.chapEnd.toInt,
                                                    occurrences: range.occurrences.toInt)
            self.wordsAreReady.send(w)
        }
    }
    
    func buildTextbookWords() {
        self.words.removeAll()
        for range in self.list.rangesArr  {
            let w = VocabListBuilder.buildHebrewTextbookList(sourceId: range.sourceId ?? "",
                                                             chapterStart: range.chapStart.toInt,
                                                             chapterEnd: range.chapEnd.toInt)
            self.wordsAreReady.send(w)
        }
    }
}

struct ListDetailView: View {
    @Environment(\.managedObjectContext) var context
    @ObservedObject var viewModel: ListDetailViewModel
    @State var studyWords = false
    @State var showWordInstances = false
    
    var body: some View {
        ZStack {
            List {
                if viewModel.isBuilding {
                    HStack {
                        ProgressView()
                            .progressViewStyle(.automatic)
                            .padding(.trailing)
                        Text("Building words list...")
                    }
                } else {
                    if viewModel.list.sourceType == .app {
                        Section {
                            ForEach(viewModel.words.sorted { $0.lemma < $1.lemma }) { word in
                                NavigationLink(value: word) {
                                    WordInfoRow(wordInfo: word.bound())
                                }
                                .navigationViewStyle(.stack)
                            }
                        }
                    } else {
                        ForEach(groupedTextbookWords, id: \.chapter) { group in
                            Section {
                                ForEach(group.words) { word in
                                    NavigationLink(value: word) {
                                        VStack(alignment: .leading) {
                                            WordInfoRow(wordInfo: word.bound())
                                        }
                                        .navigationViewStyle(.stack)
                                    }
                                }
                            } header: {
                                Text("Chapter \(group.chapter)")
                            }
                        }
                    }
                }
            }
            VStack {
                Spacer()
                AppButton(text: "Study Vocab", action: onStudy)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .principal) {
                NavHeaderTitleDetailView(title: viewModel.list.defaultTitle, detail: viewModel.list.defaultDetails)
            }
        }
        .fullScreenCover(isPresented: $studyWords) {
            VocabListStudyView(vocabList: $viewModel.list, allWordInfos: viewModel.words)
        }
        .navigationDestination(for: Bible.WordInfo.self) { word in
            WordInstancesView(word: word.bound())
        }
        .navigationTitle(viewModel.list.defaultTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var groupedTextbookWords: [GroupedWordInfos] {
        let wordsByChapter: [String:[Bible.WordInfo]] = Dictionary(grouping: viewModel.words, by: { $0.chapter })
        return wordsByChapter
            .map { GroupedWordInfos(chapter: $0.key.toInt, words: $0.value) }
            .sorted { $0.chapter < $1.chapter }
    }
    
    func onStudy() {
        studyWords = true
        CoreDataManager.transactionAsync(context: context) {
            self.viewModel.list.lastStudied = Date()
        }
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
