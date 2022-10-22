//
//  NewHomeView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/21/22.
//

import SwiftUI

enum Paths: Hashable {
    case reviewedWords
    case newWords
    case parsedWords
    case dueWords
    case allVocabLists
    case vocabListDetail(VocabWordList)
    case allParsingLists
    case parsingListDetail(ParsingList)
    case greekParadigms
    case hebrewParadigms
    case wordInfo(Bible.WordInfo)
    case wordInstance(Bible.WordInstance)
    case parsingSessionsList(ParsingList)
    case parsingSessionDetail(StudySession)
}

struct NewHomeView: View {
    
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \StudySessionEntry.createdAt, ascending: false)],
        predicate: NSPredicate(format: "createdAt >= %@", Date.startOfToday as CVarArg)
    ) var studySessionEntries: FetchedResults<StudySessionEntry>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VocabWordList.createdAt, ascending: true)],
        predicate: NSPredicate(format: "SELF.id != %@", "TEMP-DUE-WORD-LIST"),
        animation: .default)
    var vocabLists: FetchedResults<VocabWordList>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VocabWordList.createdAt, ascending: true)],
        animation: .default)
    var parsingLists: FetchedResults<ParsingList>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VocabWordList.createdAt, ascending: true)],
        predicate: NSPredicate(format: "SELF.id == %@", "TEMP-DUE-WORD-LIST"),
        animation: .default)
    var dueVocabLists: FetchedResults<VocabWordList>
    var dueList: VocabWordList? {
        return dueVocabLists.first
    }
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VocabWord.dueDate, ascending: false)],
        predicate: NSPredicate(format: "dueDate <= %@", Date() as CVarArg)
    ) var dueWords: FetchedResults<VocabWord>
    
    @ObservedObject var viewModel = DataDependentViewModel()
    @State var paths: [Paths] = []
    @State var showStatsInfoModal = false
    @State var showCreateListActionSheet = false
    @State var showCreateListModal = false
    @State var showCreateParsingModal = false
    @State var showSelectPresetListModal = false
    @State var showBibleReadingView = false
    let vocabSectionHeight: CGFloat = 175
    
    var body: some View {
        NavigationStack(path: $paths) {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                ScrollView {
                    StatsCard()
                    ReadBibleSection()
                    VocabListSection()
                    ParsingListSection()
                    HStack {
                        AppButton(text: "Greek Paradigms") {
                            paths.append(.greekParadigms)
                        }
//                            Spacer()
                        AppButton(text: "Hebrew Paradigms") {
                            paths.append(.hebrewParadigms)
                        }
                    }
                    .padding(.horizontal)
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .background(Color(uiColor: .secondarySystemGroupedBackground))
//                    .cornerRadius(Design.defaultCornerRadius)
//                    .padding(.horizontal)
                }
            }
            .navigationTitle("Bible Words")
            .navigationDestination(for: Paths.self) { path in
                switch path {
                case .reviewedWords:
                    WordsSeenTodayView(entryType: .reviewedWord)
                case .newWords:
                    WordsSeenTodayView(entryType: .newWord)
                case .parsedWords:
                    WordsSeenTodayView(entryType: .parsing)
                case .dueWords:
                    if let list = dueList {
                        DueWordsView(viewModel: .init(list: list))
                    } else {
                        Text("Something went wrong")
                    }
                case .allVocabLists:
                    VocabListsView()
                case .vocabListDetail(let list):
                    ListDetailView(viewModel: .init(list: list))
                case .allParsingLists:
                    ParsingListsView()
                case .parsingListDetail(let list):
                    ParsingListDetailView(viewModel: .init(list: list))
                case .parsingSessionsList(let list):
                    ParsingListSessionsView(list: list.bound())
                case .parsingSessionDetail(let session):
                    List {
                        ForEach(session.entriesArr.sorted { $0.createdAt! < $1.createdAt! }) { entry in
                            ParsingSessionEntryRow(entry: entry.bound())
                        }
                    }
                case .greekParadigms:
                    Text("Coming soon...")
                case .hebrewParadigms:
                    ParadigmsViews()
                case .wordInfo(let info):
                    WordInfoDetailsView(word: info)
                case .wordInstance(let instance):
                    WordInPassageView(word: instance.wordInfo.bound(), instance: instance.bound())
                }
            }
        }
        .fullScreenCover(isPresented: $showBibleReadingView) {
            NavigationStack {
                BibleReadingView()
            }
        }
        .actionSheet(isPresented: $showCreateListActionSheet) {
            ActionSheet(
                title: Text("Create new vocab list"),
                message: Text("Would you like to create a custom vocab word list, or select a preset vocab list type?"), buttons: [
                    .cancel(),
                    .default(Text("Custom List")) {
                        showCreateListModal = true
                    },
                    .default(Text("Preset List")) {
                        showSelectPresetListModal = true
                    }
                ])
        }
        .sheet(isPresented: $showStatsInfoModal) {
            StatsInfoModal()
                .presentationDetents([.fraction(0.9)])
        }
        .sheet(isPresented: $showCreateListModal) {
            NavigationStack {
                BuildVocabListView()
            }
        }
        .sheet(isPresented: $showSelectPresetListModal) {
            NavigationStack {
                DefaultVocabListSelectorView()
            }
        }
        .onAppear {
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            } else {
                fetchData()
                initializeCoreData()
            }
        }
    }
    
    func fetchData() {
        Task {
            guard !API.main.coreDataReadyPublisher.value else { return }
            await API.main.fetchHebrewDict()
            await API.main.fetchHebrewBible()
            await API.main.fetchGreekDict()
            await API.main.fetchGreekBible()
            
            await API.main.fetchGarretHebrew()
            API.main.coreDataReadyPublisher.send(true)
        }
    }
    
    func initializeCoreData() {
        if dueVocabLists.first == nil {
            CoreDataManager.transactionAsync(context: context) {
                let dueWordsList = VocabWordList(context: context)
                dueWordsList.id = "TEMP-DUE-WORD-LIST"
                dueWordsList.title = "Due words list"
                dueWordsList.details = "A temporary vocab list to handle the words that are currently due, regardless of their list"
                dueWordsList.lastStudied = Date()
                dueWordsList.createdAt = Date()
            }
        }
    }
}

extension NewHomeView {
    @ViewBuilder
    func StatsCard() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Today's Stats")
                    .font(.headline)
                Spacer()
                Button(action: {
                    showStatsInfoModal = true
                }, label: {
                    Image(systemName: "info.circle")
                        .font(.title3)
                })
            }
            Divider()
            HStack(alignment: .top) {
                Button(action: {
                    paths.append(.reviewedWords)
                }, label: {
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .foregroundColor(.accentColor)
                            .font(.title3)
                        Text("\(studySessionEntries.filter { $0.studyTypeInt == 1 }.count) ")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                })
                Button(action: {
                    paths.append(.newWords)
                }, label: {
                    VStack(spacing: 4) {
                        Image(systemName: "gift")
                            .foregroundColor(.accentColor)
                            .font(.title3)
                        Text("\(studySessionEntries.filter { $0.studyTypeInt == 0 }.count)")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                })
                Button(action: {
                    paths.append(.parsedWords)
                }, label: {
                    VStack(spacing: 4) {
                        Image(systemName: "rectangle.and.hand.point.up.left.filled")
                            .foregroundColor(.accentColor)
                            .font(.title3)
                        Text("\(studySessionEntries.filter { $0.studyTypeInt == 2 }.count)")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                })
                Button(action: {
                    paths.append(.dueWords)
                }, label: {
                    VStack(spacing: 4) {
                        Image(systemName: "clock.badge.exclamationmark")
                            .foregroundColor(.accentColor)
                            .font(.title3)
                        Text("\(dueWords.filter { ($0.list?.count ?? 0) > 0 }.count)")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                })
            }
            .padding(.top, 4)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(Design.defaultCornerRadius)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func StatsInfoModal() -> some View {
        List {
            Section {
                VStack(alignment: .leading) {
                    Text("Stats Info")
                        .font(.title)
                        .padding(.bottom, 4)
                    Text("What do those images and numbers mean?")
                        .font(.headline)
                        .padding(.bottom, 4)
                    Text("Tap any of the icons on the home screen to see more information")
                        .font(.subheadline)
                }
            }
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.title)
                        .foregroundColor(.accentColor)
                        .padding(.trailing)
                        .padding(.leading, -16)
                    Text("This represents the vocab words that you have previously learned but have reviewed today. Every day this will be set to 0 and the count will increase as you review previous vocab words")
                        .multilineTextAlignment(.leading)
                    
                }
                Divider()
                HStack(alignment: .center) {
                    Image(systemName: "gift")
                        .font(.title)
                        .foregroundColor(.accentColor)
                        .padding(.trailing)
                        .padding(.leading, -16)
                    Text("This represents the new words that you were exposed to today. Once exposed, they are given a due date and you will see them later. At that point they will become 'reviewed' words.")
                }
                Divider()
                HStack(alignment: .center) {
                    Image(systemName: "rectangle.and.hand.point.up.left.filled")
                        .font(.title)
                        .foregroundColor(.accentColor)
                        .padding(.trailing)
                        .padding(.leading, -16)
                    Text("This represents the number of words that you have parsed today. Learning biblical greek and hebrew is more than just vocabulary. Make sure to spend time practicing your parsing.")
                }
                Divider()
                HStack(alignment: .center) {
                    Image(systemName: "clock.badge.exclamationmark")
                        .font(.title)
                        .foregroundColor(.accentColor)
                        .padding(.trailing)
                        .padding(.leading, -16)
                    Text("This represents the number of vocab words that are past due. You have already seen these words before and it is time for you to review them again")
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder
    func ReadBibleSection() -> some View {
        if viewModel.isBuilding {
            DataLoadingRow()
                .padding()
                .frame(maxWidth: .infinity)
                .frame(height: 55)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(Design.defaultCornerRadius)
                .padding(.horizontal)
                .padding(.bottom)
        } else {
            AppButton(text: "Read Bible", systemImage: "book.fill") {
                showBibleReadingView = true
            }
            .padding(.horizontal)
            .disabled(viewModel.isBuilding)
            .padding(.bottom)
        }
    }
    
    @ViewBuilder
    func VocabListSection() -> some View {
        VStack {
            HStack(alignment: .lastTextBaseline) {
                Text("Your Vocab Lists")
                    .font(.title2)
                    .bold()
                    .padding(.bottom, -12)
                    .padding(.trailing)
                Button(action: { showCreateListActionSheet = true }, label: {
                    Image(systemName: "plus.circle")
                        .font(.title3)
                })
                Spacer()
                Button(action: { paths.append(.allVocabLists) }, label: {
                    Text("See all")
                        .bold()
                })
            }
            .padding(.horizontal)
            ScrollView(.horizontal) {
                HStack {
                    ForEach(vocabLists) { list in
                        GeometryReader { geo in
                            VocabListCard(list: list.bound())
                                .rotation3DEffect(Angle(degrees: Double(geo.frame(in: .global).minX) - 40) / -20, axis: (x: 0, y: 10, z: 0))
                                .onTapGesture {
                                    paths.append(.vocabListDetail(list))
                                }
                        }
                        .frame(width: 200, height: vocabSectionHeight * 0.8)
                    }
                }
                .padding()
//                .background(Color.blue.opacity(0.1))
            }
            .scrollIndicators(.hidden)
            .frame(height: vocabSectionHeight)
//            .background(Color.red.opacity(0.1))
        }
    }
    
    @ViewBuilder
    func VocabListCard(list: Binding<VocabWordList>) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(list.wrappedValue.defaultTitle)
                    .font(.title3)
                    .bold()
                Text(list.wrappedValue.defaultDetails)
                    .padding(.bottom, 4)
                Text("\(list.wrappedValue.dueWords.filter { $0.list?.count ?? 0 > 1 }.count) words due")
                    .font(.subheadline)
                    .padding(.bottom, 4)
                Spacer()
                Text("Last studied: \((list.lastStudied.wrappedValue ?? Date()).toShortPrettyDate)")
                    .font(.caption)
            }
            .padding()
            Spacer()
        }
        .frame(width: 200, height: vocabSectionHeight * 0.8)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(Design.defaultCornerRadius)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    @ViewBuilder
    func ParsingListSection() -> some View {
        VStack {
            HStack(alignment: .lastTextBaseline) {
                Text("Your Parsing Lists")
                    .font(.title2)
                    .bold()
                    .padding(.bottom, -12)
                    .padding(.trailing)
                Button(action: { showCreateParsingModal = true }, label: {
                    Image(systemName: "plus.circle")
                        .font(.title3)
                })
                Spacer()
                Button(action: { paths.append(.allParsingLists) }, label: {
                    Text("See all")
                        .bold()
                })
            }
            .padding(.horizontal)
            ScrollView(.horizontal) {
                HStack {
                    ForEach(parsingLists) { list in
                        GeometryReader { geo in
                            ParsingListCard(list: list.bound())
                                .rotation3DEffect(Angle(degrees: Double(geo.frame(in: .global).minX) - 40) / -20, axis: (x: 0, y: 10, z: 0))
                                .onTapGesture {
                                    paths.append(.parsingListDetail(list))
                                }
                        }
                        .frame(width: 200, height: vocabSectionHeight * 0.8)
                    }
                }
                .padding()
            }
            .scrollIndicators(.hidden)
            .frame(height: vocabSectionHeight)
        }
    }
    
    @ViewBuilder
    func ParsingListCard(list: Binding<ParsingList>) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(list.wrappedValue.defaultTitle)
                    .font(.title3)
                    .bold()
                Text(list.wrappedValue.defaultDetails)
                    .padding(.bottom, 4)
                Spacer()
                Text("Last studied: \((list.lastStudied.wrappedValue ?? Date()).toShortPrettyDate)")
                    .font(.caption)
            }
            .padding()
            Spacer()
        }
        .frame(width: 200, height: vocabSectionHeight * 0.8)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(Design.defaultCornerRadius)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct NewHomeView_Previews: PreviewProvider {
    static var previews: some View {
        NewHomeView()
    }
}
