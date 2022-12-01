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
    @Published var timer: Publishers.Autoconnect<Timer.TimerPublisher>? = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @Published var wordIds: [String] = []
    @Published var words: [Bible.WordInfo] = []
    @Published var studyWords = false
    var wordsAreReady = CurrentValueSubject<[Bible.WordInfo], Never>([])
    private var subscribers: [AnyCancellable] = []
    
    init(list: VocabWordList, autoStudy: Bool = false) {
        self.list = list
        self.autoStudy = autoStudy
        
        Task {
            API.main.coreDataReadyPublisher.sink { [weak self] isReady in
                if isReady {
                    self?.buildBibleWords()
                }
            }.store(in: &self.subscribers)
        }
        
        wordsAreReady.sink { [weak self] builtWords in
            DispatchQueue.main.async {
                if !builtWords.isEmpty {
                    self?.timer?.upstream.connect().cancel()
                    self?.timer = nil
                    self?.wordIds = builtWords.map { $0.id }
                    self?.words = builtWords.uniqueInfos
                    self?.isBuilding = false
                    if self?.autoStudy == true {
                        self?.studyWords = true
                    }
                }
            }
        }.store(in: &subscribers)
        
        timer?.sink { [weak self] _ in
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
    enum Filter: CaseIterable {
        case all
        case new
        case due
        
        var title: String {
            switch self {
            case .all: return "All"
            case .new: return "New"
            case .due: return "Due"
            }
        }
    }
    
    @Environment(\.managedObjectContext) var context
    @ObservedObject var viewModel: ListDetailViewModel
    @State var showWordInstances = false
    @State var showEditView = false
    @State var wordFilter = Filter.all
    @State var showFilterActionSheet = false
    @State var studyWords = false
    @State var showReadingView = false
    
    // MARK: Settings State
    @State var showSettings = false
    @State var isPinned = false
    
    var allWords: [Bible.WordInfo] {
        viewModel.words
    }
    
    var newWords: [Bible.WordInfo] {
        viewModel.words.filter { $0.isNewVocab(context: context) }
    }
    
    var dueWords: [Bible.WordInfo] {
        viewModel.list.wordsArr.filter { $0.isDue }.map { $0.wordInfo }
    }
    
    var sortedWords: [Bible.WordInfo] {
        return words(for: wordFilter).sortedInfos
    }
    
    var body: some View {
        List {
            if viewModel.isBuilding {
                DataLoadingRow(text: "Building vocab data...")
            } else {
                ActionsSection()
                WordsSection()
            }
        }
        .buttonStyle(.borderless)
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .confirmationDialog("Filter Words", isPresented: $showFilterActionSheet, actions: {
            LabelButton(title: "All words: \(viewModel.words.count)", systemImage: "") {
                wordFilter = .all
            }
            LabelButton(title: "New words: \(viewModel.words.filter { $0.isNewVocab(context: context) }.count)", systemImage: "") {
                wordFilter = .new
            }
            LabelButton(title: "Due words: \(viewModel.list.wordsArr.filter { $0.isDue }.count)", systemImage: "") {
                wordFilter = .due
            }
        }, message: {
            Text("Filter Words")
        })
        .fullScreenCover(isPresented: $studyWords) {
            StudyVocabWordsView(vocabList: viewModel.list, allWordInfoIds: viewModel.wordIds)
        }
        .fullScreenCover(isPresented: $showReadingView) {
            if let firstRange = viewModel.list.rangesArr.first {
                NavigationView {
                    BibleReadingView(passage: .init(get: {.init(
                        book: Bible.Book(rawValue: firstRange.bookStart.toInt) ?? .genesis,
                        chapter: firstRange.chapStart.toInt,
                        verse: -1
                    )}, set: { _ in}))
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    studyWords = true
                }, label: {
                    Label("Study", systemImage: "brain.head.profile")
                })
                .labelStyle(.titleAndIcon)
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
    
    func words(for filter: Filter) -> [Bible.WordInfo] {
        switch filter {
        case .all:
            return allWords
        case .new:
            return newWords
        case .due:
            return dueWords
        }
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
        .padding(.horizontal, Design.viewHorziontalPadding)
    }
    
    @ViewBuilder
    func FilterSection() -> some View {
        HStack {
            Button(action: { wordFilter = .all }, label: {
                VStack {
                    Text("Total")
                    Text("\(viewModel.words.count)")
                        .bold()
                }
                .font(.subheadline)
            })
            .frame(maxWidth: .infinity)
            Button(action: { wordFilter = .new }, label: {
                VStack {
                    Text("New")
                    Text("\(viewModel.words.filter { $0.isNewVocab(context: context) }.count)")
                        .bold()
                }
                .font(.subheadline)
            })
            .frame(maxWidth: .infinity)
            Button(action: { wordFilter = .due }, label: {
                VStack {
                    Text("Due")
                    Text("\(viewModel.list.wordsArr.filter { $0.isDue }.count)")
                        .bold()
                }
                .font(.subheadline)
                
            })
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    func ActionsSection() -> some View {
        Section {
            HStack {
                if viewModel.list.rangesArr.first != nil {
                    Button(action: { showReadingView = true }, label: {
                        HStack {
                            Image(systemName: "books.vertical")
                            Text("Read")
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.accentColor)
                        .cornerRadius(12)
                    })
                }
                Button(action: {
                    CoreDataManager.transaction(context: context) {
                        if viewModel.list.pin == nil {
                            let pin = PinnedItem(context: context)
                            pin.id = UUID().uuidString
                            pin.createdAt = Date()
                            pin.pinTitle = viewModel.list.defaultTitle
                            pin.vocabList = viewModel.list
                        } else if let pin = viewModel.list.pin {
                            context.delete(pin)
                        }
                    }
                }, label: {
                    HStack {
                        Image(systemName: viewModel.list.pin == nil ? "pin" : "pin.slash")
                        Text(viewModel.list.pin == nil ? "Pin" : "Unpin")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color.accentColor)
                    .cornerRadius(12)
                })
            }
            .padding(.bottom, 8)
            Picker(selection: $wordFilter, content: {
                ForEach(Filter.allCases, id: \.title) { filter in
                    Text("\(filter.title): \(words(for: filter).count)").tag(filter)
                }
            }, label: {})
            .frame(height: 40)
            .labelsHidden()
            .pickerStyle(.segmented)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        .listRowBackground(Color.appBackground)
        .foregroundColor(.white)
    }
    
    @ViewBuilder
    func WordsSection() -> some View {
        Section {
            ForEach(sortedWords) { word in
                NavigationLink(destination: {
                    WordInfoDetailsView(word: word.bound())
                }) {
                    WordInfoRow(wordInfo: word.bound())
                }
            }
        } header: {
            Text("\(words(for: wordFilter).count) words")
        }
    }
    
    @ViewBuilder
    func SettingsView() -> some View {
        NavigationView {
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
                                            pin.pinTitle = viewModel.list.defaultTitle
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
