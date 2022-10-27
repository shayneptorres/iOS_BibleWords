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
    @Published var animationRotationAngle: CGFloat = 0.0
    @Published var timer: Publishers.Autoconnect<Timer.TimerPublisher> = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @Published var wordIds: [String] = []
    @Published var words: [Bible.WordInfo] = []
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
                    self?.timer.upstream.connect().cancel()
//                    self?.wordIds = builtWords.map { $0.id }
                    self?.words = builtWords.uniqueInfos
                    self?.isBuilding = false
                    if self?.autoStudy == true {
                        self?.studyWords = true
                    }
                }
            }
        }.store(in: &subscribers)
        
        timer.sink { [weak self] _ in
            self?.animationRotationAngle += 360
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
    enum Filter {
        case all
        case new
        case due
    }
    
    @Environment(\.managedObjectContext) var context
    @ObservedObject var viewModel: ListDetailViewModel
    @State var showWordInstances = false
    @State var showEditView = false
    @State var wordFilter = Filter.all
    @State var studyWords = false
    
    // MARK: Settings State
    @State var showSettings = false
    @State var isPinned = false
    
    var filteredWords: [Bible.WordInfo] {
        switch wordFilter {
        case .all:
            return viewModel.words
        case .new:
            return viewModel.words.filter { $0.isNewVocab(context: context) }
        case .due:
            return viewModel.list.wordsArr.filter { $0.isDue }.map { $0.wordInfo }
        }
    }
    
    var body: some View {
        ZStack {
            Color
                .appBackground
                .ignoresSafeArea()
            ScrollView {
                if viewModel.isBuilding {
                    DataIsBuildingCard(rotationAngle: $viewModel.animationRotationAngle)
                        .padding(.horizontal, 12)
                } else {
                    WordFilterSection()
                    WordsSection()
                }
                Spacer()
                    .frame(height: 150)
            }
            StudyButton()
        }
        .toolbar {
            ToolbarItemGroup(placement: .principal) {
                NavHeaderTitleDetailView(title: viewModel.list.defaultTitle, detail: viewModel.list.defaultDetails)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showSettings = true
                }, label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                })
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showEditView) {
            if viewModel.list.rangesArr.isEmpty {
                CustomWordListBuilderView(viewModel: .init(list: $viewModel.list)) { editedList in
                    viewModel.list = editedList
                }
            } else {
                
            }
        }
        .fullScreenCover(isPresented: $studyWords) {
            if #available(iOS 16.1, *) {
                VocabListStudyView(vocabList: $viewModel.list, allWordInfoIds: viewModel.wordIds)
            } else {
                VocabListStudyView(vocabList: $viewModel.list, allWordInfoIds: viewModel.wordIds)
            }
        }
        .navigationTitle(viewModel.list.defaultTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isPinned = viewModel.list.pin != nil
        }
    }
    
    var groupedTextbookWords: [GroupedWordInfos] {
        let wordInfos = viewModel.wordIds.compactMap { $0.toWordInfo }
        let wordsByChapter: [String:[Bible.WordInfo]] = Dictionary(grouping: wordInfos, by: { $0.chapter })
        return wordsByChapter
            .map { GroupedWordInfos(chapter: $0.key.toInt, words: $0.value) }
            .sorted { $0.chapter < $1.chapter }
    }
    
    func onStudy() {
        self.studyWords = true
        CoreDataManager.transactionAsync(context: context) {
            self.viewModel.list.lastStudied = Date()
        }
    }
}

extension ListDetailView {
 
    @ViewBuilder
    func WordFilterSection() -> some View {
        HStack {
            Button(action: {
                wordFilter = .all
            }, label: {
                VStack {
                    Image(systemName: "sum")
                        .font(.title2)
                        .padding(.bottom, 4)
                    Text("All: \(viewModel.words.count)")
                        .font(.caption2)
                }
                .foregroundColor(wordFilter == .all ? .white : .accentColor)
                .appCard(height: 60, backgroundColor: wordFilter == .all ? .accentColor : Color(uiColor: .secondarySystemGroupedBackground))
            })
            Button(action: {
                wordFilter = .new
            }, label: {
                VStack {
                    Image(systemName: "gift")
                        .font(.title2)
                        .padding(.bottom, 4)
                    Text("New: \(viewModel.words.filter { $0.isNewVocab(context: context) }.count)")
                        .font(.caption2)
                }
                .foregroundColor(wordFilter == .new ? .white : .accentColor)
                .appCard(height: 60, backgroundColor: wordFilter == .new ? .accentColor : Color(uiColor: .secondarySystemGroupedBackground))
            })
            Button(action: {
                wordFilter = .due
            }, label: {
                VStack {
                    Image(systemName: "clock.badge.exclamationmark")
                        .font(.title2)
                        .padding(.bottom, 4)
                    Text("Due: \(viewModel.list.wordsArr.filter { $0.isDue }.count)")
                        .font(.caption2)
                }
                .foregroundColor(wordFilter == .due ? .white : .accentColor)
                .appCard(height: 60, backgroundColor: wordFilter == .due ? .accentColor : Color(uiColor: .secondarySystemGroupedBackground))
            })
        }
        .padding(.horizontal, 12)
    }
    
    @ViewBuilder
    func WordsSection() -> some View {
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
        } else {
            ForEach(filteredWords) { word in
                NavigationLink(value: AppPath.wordInfo(word)) {
                    HStack {
                        WordInfoRow(wordInfo: word.bound())
                        Spacer()
                        Image(systemName: "arrow.forward.circle")
                            .font(.title3)
                            .foregroundColor(.accentColor)
                    }
                }
                    .appCard(outerPadding: 4)
                    .padding(.horizontal, 16)
            }
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
    
    @ViewBuilder
    func SettingsView() -> some View {
        NavigationStack {
            ZStack {
                Color
                    .appBackground
                    .ignoresSafeArea()
                ScrollView {
                    VStack {
                        HStack {
                            Text("Pin List")
                            Spacer()
                            Toggle(isOn: $isPinned, label: {})
                                .onChange(of: isPinned) { bool in
                                    CoreDataManager.transaction(context: context) {
                                        if bool && viewModel.list.pin == nil {
                                            
                                            let pin = PinnedItem(context: context)
                                            pin.id = UUID().uuidString
                                            pin.createdAt = Date()
                                            pin.pinTitle = viewModel.list.title
                                            pin.vocabList = viewModel.list
                                        } else if let pin = viewModel.list.pin {
                                            context.delete(pin)
                                        }
                                    }
                                }
                        }
                        .appCard(height: 30)
                        
                    }
                    .padding(12)
                }
            }
            .toolbar {
                Button(action: {
                    showSettings = false
                }, label: {
                    Text("Dismiss")
                        .bold()
                })
            }
        }
    }
}
