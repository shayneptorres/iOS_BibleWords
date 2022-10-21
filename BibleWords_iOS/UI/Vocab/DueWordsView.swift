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
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VocabWordList.createdAt, ascending: true)],
        predicate: NSPredicate(format: "SELF.id == %@", "TEMP-DUE-WORD-LIST"),
        animation: .default)
    var dueVocabLists: FetchedResults<VocabWordList>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VocabWord.dueDate, ascending: false)],
        predicate: NSPredicate(format: "dueDate <= %@", Date() as CVarArg)
    ) var dueWords: FetchedResults<VocabWord>
    @Environment(\.managedObjectContext) var context
    
    @ObservedObject var viewModel = DueWordsViewModel()
    @State var langFilter: Language = .all
    @State var showStudyWordsView = false
    @State var studyWords: [VocabWord] = []
    
    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                if viewModel.isBuilding {
                    DataLoadingRow()
                } else {
                    Section {
                        Picker("Language", selection: $langFilter) {
                            Text("All").tag(Language.all)
                            Text("Greek").tag(Language.greek)
                            Text("Hebrew").tag(Language.hebrew)
                        }.pickerStyle(.segmented)
                        Group {
                            Text("\(filteredDueWordInfos.count)")
                                .foregroundColor(.accentColor)
                                .bold()
                            +
                            Text(" words")
                        }
                    }
                    Section {
                        ForEach(filteredDueWordInfos) { wordInfo in
                            NavigationLink(value: wordInfo) {
                                WordInfoRow(wordInfo: wordInfo.bound())
                            }
                        }
                    } footer: {
                        Spacer()
                            .frame(minHeight: 100)
                    }
                }
            }
            AppButton(text: "Study Words", action: onStudyWords)
            .padding(.bottom)
            .disabled(viewModel.isBuilding)
        }
        .fullScreenCover(isPresented: $showStudyWordsView) {
            if dueList == nil {
                Text("Something happened")
            } else {
                VocabListStudyView(vocabList: dueList!.bound(), allWordInfos: [])                
            }
        }
        .navigationDestination(for: Bible.WordInfo.self) { word in
            WordInstancesView(word: word.bound())
        }
        .navigationTitle("Your Due Words")
    }
    
    var filteredDueWords: [VocabWord] {
        switch langFilter {
        case .all:
            return dueWords.filter { ($0.list?.count ?? 0) > 0 }.map { $0 }
        case .greek:
            return dueWords.filter { ($0.list?.count ?? 0) > 0 && $0.lang == Language.greek.rawValue }
        case .hebrew:
            return dueWords.filter { ($0.list?.count ?? 0) > 0 && $0.lang == Language.hebrew.rawValue }
        case .aramaic:
            return []
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
        case .aramaic:
            return []
        }
    }
    
    var dueList: VocabWordList? {
        dueVocabLists.first
    }
}

extension DueWordsView {
    func onStudyWords() {
//        let dueWordsFetchRequest = NSFetchRequest<VocabWordList>(entityName: "VocabWordList")
//        dueWordsFetchRequest.predicate = NSPredicate(format: "SELF.id == %@", "TEMP-DUE-WORD-LIST")
//
//        var dueWordsLists: [VocabWordList] = []
//        do {
//            dueWordsLists = try context.fetch(dueWordsFetchRequest)
//        } catch let err {
//            print(err)
//        }
        
        if dueList == nil {
            let dueWordsList = VocabWordList(context: context)
            dueWordsList.id = "TEMP-DUE-WORD-LIST"
            dueWordsList.title = "Due words list"
            dueWordsList.details = "A temporary vocab list to handle the words that are currently due, regardless of their list"
            dueWordsList.lastStudied = Date()
            dueWordsList.createdAt = Date()
        } else {
            for word in (dueList?.wordsArr ?? []) {
                dueList?.removeFromWords(word)
            }
        }
        
        for word in filteredDueWords {
            dueList?.addToWords(word)
        }
        
        showStudyWordsView = true
    }
}

struct DueWordsView_Previews: PreviewProvider {
    static var previews: some View {
        DueWordsView()
    }
}
