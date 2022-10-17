//
//  DueWordsView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/15/22.
//

import SwiftUI
import Combine
import CoreData

class DueWordsViewModel: ObservableObject, Equatable {
    @Published var isBuilding = true
    let id = UUID().uuidString
    private var subscribers: [AnyCancellable] = []
    
    init() {
        Task {
            API.main.coreDataReadyPublisher.sink { [weak self] isReady in
                if isReady {
                    self?.isBuilding = false
                }
            }.store(in: &self.subscribers)
        }
    }
    
    static func == (lhs: DueWordsViewModel, rhs: DueWordsViewModel) -> Bool {
        return lhs.id == rhs.id
    }
}

struct DueWordsView: View, Equatable {
    static func == (lhs: DueWordsView, rhs: DueWordsView) -> Bool {
        lhs.viewModel.id == rhs.viewModel.id
    }
    
    enum DueWordLang: Int, Hashable {
        case all
        case greek
        case hebrew
    }
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VocabWord.dueDate, ascending: false)],
        predicate: NSPredicate(format: "dueDate <= %@", Date() as CVarArg)
    ) var dueWords: FetchedResults<VocabWord>
    @Environment(\.managedObjectContext) var context
    
    @State var langFilter: DueWordLang = .all
    @State var studyWords = false
    @State var dueWordVocabList: VocabWordList = .init()
    @ObservedObject var viewModel = DueWordsViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                if viewModel.isBuilding {
                    HStack {
                        ProgressView()
                            .progressViewStyle(.automatic)
                            .padding(.trailing)
                        Text("Building bible words data...")
                    }
                } else {
                    Section {
                        Picker("Language", selection: $langFilter) {
                            Text("All").tag(DueWordLang.all)
                            Text("Greek").tag(DueWordLang.greek)
                            Text("Hebrew").tag(DueWordLang.hebrew)
                        }.pickerStyle(.segmented)
                        Group {
                            Text("\(filteredDueWordInfos.count)")
                                .foregroundColor(.accentColor)
                                .bold()
                            +
                            Text(" words")
                        }
                    }
                    ForEach(filteredDueWordInfos) { wordInfo in
                        WordInfoRow(wordInfo: wordInfo.bound())
                    }
                }
            }
            AppButton(text: "Study Words", action: onStudyWords)
            .padding(.bottom)
            .disabled(viewModel.isBuilding)
        }
        .fullScreenCover(isPresented: $studyWords) {
            VocabListStudyView(
                vocabList: $dueWordVocabList,
                allWordInfos: filteredDueWordInfos)
        }
        .navigationTitle("Your Due Words")
    }
    
    var filteredDueWords: [VocabWord] {
        switch langFilter {
        case .all:
            return dueWords.filter { ($0.list?.count ?? 0) > 0 }.map { $0 }
        case .greek:
            return dueWords.filter { ($0.list?.count ?? 0) > 0 && $0.lang == VocabWord.Language.greek.rawValue }
        case .hebrew:
            return dueWords.filter { ($0.list?.count ?? 0) > 0 && $0.lang == VocabWord.Language.hebrew.rawValue }
        }
    }
    
    var filteredDueWordInfos: [Bible.WordInfo] {
        switch langFilter {
        case .all:
            return filteredDueWords.map { $0.wordInfo }
        case .greek:
            return filteredDueWords.map { $0.wordInfo }
        case .hebrew:
            return filteredDueWords.map { $0.wordInfo }
        }
    }
}

extension DueWordsView {
    func onStudyWords() {
        let dueWordsFetchRequest = NSFetchRequest<VocabWordList>(entityName: "VocabWordList")
        dueWordsFetchRequest.predicate = NSPredicate(format: "SELF.id == %@", "TEMP-DUE-WORD-LIST")

        var dueWordsLists: [VocabWordList] = []
        do {
            dueWordsLists = try context.fetch(dueWordsFetchRequest)
        } catch let err {
            print(err)
        }
        
        var dueWordsList: VocabWordList?
        if dueWordsLists.isEmpty {
            dueWordsList = VocabWordList(context: context)
            dueWordsList?.id = "TEMP-DUE-WORD-LIST"
            dueWordsList?.title = "Due words list"
            dueWordsList?.details = "A temporary vocab list to handle the words that are currently due, regardless of their list"
            dueWordsList?.lastStudied = Date()
            dueWordsList?.createdAt = Date()
        } else {
            dueWordsList = dueWordsLists.first
            for word in (dueWordsList?.wordsArr ?? []) {
                dueWordsList?.removeFromWords(word)
            }
        }
        
        for word in filteredDueWords {
            dueWordsList?.addToWords(word)
        }
        dueWordVocabList = dueWordsList!
        studyWords = true
    }
}

struct DueWordsView_Previews: PreviewProvider {
    static var previews: some View {
        DueWordsView()
    }
}
