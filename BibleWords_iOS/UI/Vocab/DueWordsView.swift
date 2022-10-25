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
    @Published var dueList: VocabWordList
    let id = UUID().uuidString
    private var subscribers: [AnyCancellable] = []
    
    init(list: VocabWordList) {
        self.dueList = list
        Task {
            API.main.coreDataReadyPublisher.sink { [weak self] isReady in
                if isReady {
                    self?.isBuilding = false
                }
            }.store(in: &self.subscribers)
        }
    }
    
    static func == (lhs: DueWordsViewModel, rhs: DueWordsViewModel) -> Bool {
        return lhs.dueList.id == rhs.dueList.id
    }
}

struct DueWordsView: View, Equatable {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VocabWord.dueDate, ascending: false)],
        predicate: NSPredicate(format: "dueDate <= %@ && currentInterval > 0", Date() as CVarArg)
    ) var dueWords: FetchedResults<VocabWord>
    @Environment(\.managedObjectContext) var context
    
    @ObservedObject var viewModel: DueWordsViewModel
    @State var langFilter: Language = .all
    @State var showStudyWordsView = false
    @State var studyWords: [VocabWord] = []
    
    static func == (lhs: DueWordsView, rhs: DueWordsView) -> Bool {
        lhs.viewModel.dueList.id == rhs.viewModel.dueList.id
    }
    
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
                            NavigationLink(value: AppPath.wordInfo(wordInfo)) {
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
                .padding([.horizontal, .bottom])
            .disabled(viewModel.isBuilding)
        }
        .fullScreenCover(isPresented: $showStudyWordsView) {
            VocabListStudyView(vocabList: $viewModel.dueList, allWordInfoIds: [])
        }
        .navigationDestination(for: Bible.WordInfo.self) { word in
            WordInfoDetailsView(word: word)
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
}

extension DueWordsView {
    func onStudyWords() {
        for word in (viewModel.dueList.wordsArr) {
            viewModel.dueList.removeFromWords(word)
        }
        
        for word in filteredDueWords {
            viewModel.dueList.addToWords(word)
        }
        
        showStudyWordsView = true
    }
}

//struct DueWordsView_Previews: PreviewProvider {
//    static var previews: some View {
//        DueWordsView()
//    }
//}
