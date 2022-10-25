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
    @Published var autoStudy: Bool = false
    @Published var isBuilding = true
    @Published var wordIds: [String] = []
    @Published var studyWords = false
    var wordsAreReady = CurrentValueSubject<[Bible.WordInfo], Never>([])
    private var subscribers: [AnyCancellable] = []
    
    init(list: VocabWordList, autoStudy: Bool = false) {
        self.list = list
        self.autoStudy = autoStudy
        
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
        
        wordsAreReady.sink { [weak self] builtWords in
            DispatchQueue.main.async {
                if !builtWords.isEmpty {
                    self?.wordIds = builtWords.map { $0.id }
                    self?.isBuilding = false
                    if self?.autoStudy == true {
                        self?.studyWords = true
                    }
                }
            }
        }.store(in: &subscribers)
    }
    
    static func == (lhs: ListDetailViewModel, rhs: ListDetailViewModel) -> Bool {
        return (lhs.list.id ?? "") == (rhs.list.id ?? "") &&
        (lhs.list.title ?? "") == (rhs.list.title ?? "") &&
        (lhs.list.details ?? "") == (rhs.list.details ?? "")
    }
    
    func buildBibleWords() {
        var w: [Bible.WordInfo] = []
        for range in self.list.rangesArr  {
            w = VocabListBuilder.buildVocabList(bookStart: range.bookStart.toInt,
                                                    chapStart: range.chapStart.toInt,
                                                    bookEnd: range.bookEnd.toInt,
                                                    chapEnd: range.chapEnd.toInt,
                                                    occurrences: range.occurrences.toInt)
        }
        
        for vocabWord in list.wordsArr {
            // get any remaining words that are part of this list but not from a bible/textbook range
            if !w.contains(vocabWord.wordInfo) {
                w.append(vocabWord.wordInfo)
            }
        }
        
        w = w.filter { !$0.id.isEmpty }
        
        self.wordsAreReady.send(w)
    }
    
    func buildTextbookWords() {
        self.wordIds.removeAll()
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
    @State var showWordInstances = false
    @State var showEditView = false
    
    var body: some View {
        ZStack {
            List {
                if viewModel.isBuilding {
                    DataLoadingRow(text: "Building list data...")
                } else {
                    ListInfoSection()
                    TextbookWordsSection()
                }
            }
            StudyButton()
        }
        .toolbar {
            ToolbarItemGroup(placement: .principal) {
                NavHeaderTitleDetailView(title: viewModel.list.defaultTitle, detail: viewModel.list.defaultDetails)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showEditView = true
                }, label: {
                    Text("Edit")
                        .bold()
                })
            }
        }
        .sheet(isPresented: $showEditView) {
            if viewModel.list.rangesArr.isEmpty {
                CustomWordListBuilderView(viewModel: .init(list: $viewModel.list)) { editedList in
                    viewModel.list = editedList
                }
            } else {
                
            }
        }
        .fullScreenCover(isPresented: $viewModel.studyWords) {
            VocabListStudyView(vocabList: $viewModel.list, allWordInfoIds: viewModel.wordIds)
        }
        .navigationTitle(viewModel.list.defaultTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var groupedTextbookWords: [GroupedWordInfos] {
        let wordInfos = viewModel.wordIds.compactMap { $0.toWordInfo }
        let wordsByChapter: [String:[Bible.WordInfo]] = Dictionary(grouping: wordInfos, by: { $0.chapter })
        return wordsByChapter
            .map { GroupedWordInfos(chapter: $0.key.toInt, words: $0.value) }
            .sorted { $0.chapter < $1.chapter }
    }
    
    func onStudy() {
        viewModel.studyWords = true
        CoreDataManager.transactionAsync(context: context) {
            self.viewModel.list.lastStudied = Date()
        }
    }
}

extension ListDetailView {
 
    @ViewBuilder
    func ListInfoSection() -> some View {
        Section {
            HStack {
                NavigationLink(value: AppPath.wordInfoList(viewModel.wordIds.compactMap { $0.toWordInfo })) {
                    Image(systemName: "sum")
                        .font(.title3)
                    Text("Total Words: \(viewModel.wordIds.count)")
                }
            }
            .foregroundColor(.accentColor)
            HStack {
                NavigationLink(value: AppPath.wordInfoList(viewModel.wordIds.compactMap { $0.toWordInfo }.filter { $0.isNewVocab(context: context) })) {
                    Image(systemName: "gift")
                        .font(.title3)
                    Text("New Words: \(viewModel.wordIds.compactMap { $0.toWordInfo }.filter { $0.isNewVocab(context: context) }.count)")
                }
            }
            .foregroundColor(.accentColor)
            HStack {
                NavigationLink(value: AppPath.wordInfoList(viewModel.list.wordsArr.filter { $0.isDue }.map { $0.wordInfo })) {
                    Image(systemName: "clock.badge.exclamationmark")
                        .font(.title3)
                    Text("Due Words: \(viewModel.list.wordsArr.filter { $0.isDue }.count)")
                }
            }
            .foregroundColor(.accentColor)
        } header: {
            Text("List info")
        }
    }
    
    @ViewBuilder
    func TextbookWordsSection() -> some View {
        if viewModel.list.sourceType == .textbook {
            ForEach(groupedTextbookWords, id: \.chapter) { group in
                Section {
                    ForEach(group.words) { word in
                        NavigationLink(value: AppPath.wordInfo(word)) {
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
    
    @ViewBuilder
    func StudyButton() -> some View {
        VStack {
            Spacer()
            AppButton(text: "Study Vocab", action: onStudy)
                .padding([.horizontal, .bottom])
        }
    }
}

//struct ListDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            ListDetailView(viewModel: .init(list: .init(context: PersistenceController.preview.container.viewContexts)))
//        }
//    }
//}
