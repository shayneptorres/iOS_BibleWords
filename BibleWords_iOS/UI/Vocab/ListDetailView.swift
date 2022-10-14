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
    @Published var isBibleDataReady = false
    @Published var isTextbookDataReady = false
    @Published var words: [Bible.WordInfo] = []
    var hereAreTheBuiltWords = CurrentValueSubject<[Bible.WordInfo], Never>([])
    private var subscribers: [AnyCancellable] = []
    
    init(list: VocabWordList) {
        self.list = list
        
        if list.sourceType == .app {
            API.main.coreDataReadyPublisher.sink { [weak self] isReady in
                if isReady {
                    self?.buildBibleWords()
                }
            }.store(in: &subscribers)
        } else {
            API.main.builtTextbooks.sink { [weak self] builtTextbooks in
                if builtTextbooks.contains(.garretHebrew) {
                    self?.buildTextbookWords()
                } else {
                    Task {
                        await API.main.fetchGarretHebrew()
                    }
                }
            }.store(in: &subscribers)
        }
        
        hereAreTheBuiltWords.sink { w in
            self.words = w
            if list.sourceType == .app {
                self.isBibleDataReady = true
            } else {
                self.isTextbookDataReady = true
            }
        }.store(in: &subscribers)
    }
    
    static func == (lhs: ListDetailViewModel, rhs: ListDetailViewModel) -> Bool {
        return (lhs.list.id ?? "") == (rhs.list.id ?? "")
    }
    
    func buildBibleWords() {
        DispatchQueue.main.async {
            for range in self.list.rangesArr  {
                let w = VocabListBuilder.buildVocabList(bookStart: range.bookStart.toInt,
                                                        chapStart: range.chapStart.toInt,
                                                        bookEnd: range.bookEnd.toInt,
                                                        chapEnd: range.chapEnd.toInt,
                                                        occurrences: range.occurrences.toInt)
                self.hereAreTheBuiltWords.send(w)
            }
        }
    }
    
    func buildTextbookWords() {
        self.words.removeAll()
        DispatchQueue.main.async {
            for range in self.list.rangesArr  {
                let w = VocabListBuilder.buildHebrewTextbookList(sourceId: range.sourceId ?? "",
                                                                 chapterStart: range.chapStart.toInt,
                                                                 chapterEnd: range.chapEnd.toInt)
                self.hereAreTheBuiltWords.send(w)
            }
        }
    }
}

struct ListDetailView: View {
    @Environment(\.managedObjectContext) var context
    @ObservedObject var viewModel: ListDetailViewModel
    @State var isBuilding = false
    @State var studyWords = false
    @State var showWordInstances = false
    
    var body: some View {
        ZStack {
            List {
                if !viewModel.isBibleDataReady && !viewModel.isTextbookDataReady {
                    HStack {
                        ProgressView()
                            .progressViewStyle(.automatic)
                            .padding(.trailing)
                        Text("Building words list...")
                    }
                } else {
                    if viewModel.list.sourceType == .app {
                        Section {
                            ForEach(viewModel.words) { word in
                                NavigationLink(value: word) {
                                    VStack(alignment: .leading) {
                                        Text(word.lemma)
                                            .font(.bible32)
                                        Text(word.definition)
                                    }
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
                                            Text(word.lemma)
                                                .font(.bible40)
                                            Text(word.definition)
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
                Spacer().frame(height: 100)
            }
            VStack {
                Spacer()
                AppButton(text: "Study Vocab", action: onStudy)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .principal) {
                VStack {
                    Text(viewModel.list.defaultTitle)
                        .font(.headline)
                    Text(viewModel.list.defaultDetails)
                        .font(.subheadline)
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                }
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
