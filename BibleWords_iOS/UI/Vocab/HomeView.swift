//
//  HomeView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/14/22.
//

import SwiftUI
import CoreData

struct HomeView: View {
    enum Routes: Hashable {
        case allLists
        case allParsingLists
        case showList(VocabWordList)
        case showParsingList(ParsingList)
        case paradigms(Language)
        case dueWords
        case newWords
        case parsedWords
    }
    
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VocabWord.createdAt, ascending: true)],
        animation: .default)
    var words: FetchedResults<VocabWord>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VocabWordList.createdAt, ascending: true)],
        predicate: NSPredicate(format: "SELF.id != %@", "TEMP-DUE-WORD-LIST"),
        animation: .default)
    var lists: FetchedResults<VocabWordList>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VocabWordList.createdAt, ascending: true)],
        animation: .default)
    var parsingLists: FetchedResults<ParsingList>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \StudySession.startDate, ascending: false)],
        predicate: NSPredicate(format: "startDate >= %@", Date.startOfToday as CVarArg)
    ) var studySessions: FetchedResults<StudySession>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \StudySessionEntry.createdAt, ascending: false)],
        predicate: NSPredicate(format: "createdAt >= %@", Date.startOfToday as CVarArg)
    ) var studySessionEntries: FetchedResults<StudySessionEntry>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \StudySessionEntry.createdAt, ascending: false)],
        predicate: NSPredicate(format: "createdAt >= %@ AND studyTypeInt == \(SessionEntryType.parsing.rawValue)", Date.startOfToday as CVarArg)
    ) var wordsParsedToday: FetchedResults<StudySessionEntry>
    
    @ObservedObject var viewModel = DataDependentViewModel()
    @State var showReadingView = false
    
    var body: some View {
        NavigationStack {
            List {
                if viewModel.isBuilding {
                    Section {
                        DataLoadingRow()
                    }
                }
                StatsSection()
                Section {
                    if recentlyStudiedLists.isEmpty {
                        Text("Oh no! You haven't studied your vocab words in a while! You should do something about that")
                            .multilineTextAlignment(.center)
                    } else {
                        ForEach(recentlyStudiedLists) { list in
                            NavigationLink(value: Routes.showList(list)) {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(list.defaultTitle)
                                        Spacer()
                                        Text(list.defaultDetails)
                                    }
                                    .padding(.bottom)
                                    Text("Last studied on: \((list.lastStudied ?? Date()).toPrettyDate)")
                                        .font(.subheadline)
                                        .foregroundColor(Color(uiColor: .secondaryLabel))
                                }
                            }
                        }
                    }
                    NavigationLink("Your Vocab Lists", value: Routes.allLists)
                        .bold()
                        .foregroundColor(.accentColor)
                } header: {
                    Text("Vocab")
                }
                
                Section {
                    if recentlyStudiedLists.isEmpty {
                        Text("Oh no! You haven't practiced your parsing in a while! You should do something about that")
                            .multilineTextAlignment(.center)
                    } else {
                        ForEach(recentlyParsedLists) { list in
                            NavigationLink(value: Routes.showParsingList(list)) {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(list.defaultTitle)
                                        Spacer()
                                        Text(list.defaultDetails)
                                    }
                                    .padding(.bottom)
                                    Text("Last studied on: \((list.lastStudied ?? Date()).toPrettyDate)")
                                        .font(.subheadline)
                                        .foregroundColor(Color(uiColor: .secondaryLabel))
                                }
                            }
                        }
                    }
                    NavigationLink("Your Parsing Lists", value: Routes.allParsingLists)
                        .bold()
                        .foregroundColor(.accentColor)
                } header: {
                    Text("Parsing")
                }
                
                Section {
                    NavigationLink("Hebrew Paradigms", value: Routes.paradigms(.hebrew))
                        .bold()
                        .foregroundColor(.accentColor)
                    NavigationLink("Greek Paradigms", value: Routes.paradigms(.greek))
                        .bold()
                        .foregroundColor(.accentColor)
                } header: {
                    Text("Paradigms")
                }
            }
            .navigationTitle("Bible Words")
            .toolbar {
                Button(action: { showReadingView = true }, label: {
                    HStack {
                        Image(systemName: "book.fill")
                        Text("Read")
                    }
                })
                .disabled(viewModel.isBuilding)
            }
            .fullScreenCover(isPresented: $showReadingView) {
                NavigationStack {
                    BibleReadingView()
                }
            }
            .navigationDestination(for: Routes.self) { route in
                switch route {
                case .allLists:
                    VocabListsView()
                case .allParsingLists:
                    ParsingListsView()
                case .showList(let list):
                    ListDetailView(viewModel: .init(list: list))
                case .showParsingList(let list):
                    ParsingListDetailView(viewModel: .init(list: list))
                case .paradigms(let lang):
                    switch lang {
                    case .greek:
                        Text("TODO")
                    case .hebrew, .aramaic:
                        ParadigmsViews()
                    case .all:
                        Text("TODO")
                    }
                case .dueWords:
                    DueWordsView()
                case .newWords:
                    NewWordsLearnedTodayView()
                case .parsedWords:
                    AllWordsParsedTodayView()
                }
            }
            .onAppear {
                if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                } else {
//                    let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "StudySession")
//                    deleteFetch.predicate = NSPredicate(format: "SELF.startDate > %@", Date.startOfToday as CVarArg)
//                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
//
//                    do {
//                        try self.context.execute(deleteRequest)
//                        try self.context.save()
//                    } catch {
//                        // error
//                    }
                    fetchData()
                }
            }
        }
    }
    
    var dueVocabWords: [VocabWord] {
        words.filter { ($0.list?.count ?? 0) > 0 && $0.isDue }
    }
    
    var recentlyStudiedLists: [VocabWordList] {
        let recent = lists
            .sorted { $0.lastStudied ?? Date().addingTimeInterval(-Double(7.days)) > $1.lastStudied ?? Date().addingTimeInterval(-Double(7.days)) }
        
        return Array(recent.prefix(3))
    }
    
    var recentlyParsedLists: [ParsingList] {
        let recent = parsingLists
            .sorted { $0.lastStudied ?? Date().addingTimeInterval(-Double(7.days)) > $1.lastStudied ?? Date().addingTimeInterval(-Double(7.days)) }
        
        return Array(recent.prefix(3))
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
}

extension HomeView {
    func StatsSection() -> some View {
        Section {
            WordsStudiedTodayRow()
            ReviewedWordsTodayRow()
            WordsParsedTodayRow()
            NewWordsLearnedRow()
            CurrentDueWordsRow()
        } header: {
            Text("Stats")
        }
    }
    
    func WordsStudiedTodayRow() -> some View {
        Group {
            HStack {
                Image(systemName: "book")
                Text("\(studySessionEntries.filter { $0.studyType == .reviewedWord }.count)")
                    .foregroundColor(.accentColor)
                    .bold()
                +
                Text(" vocab words") +
                Text(" studied")
                    .bold()
                +
                Text(" today")
            }
        }
    }
    
    func WordsParsedTodayRow() -> some View {
        NavigationLink(value: Routes.parsedWords, label: {
            Group {
                HStack {
                    Image(systemName: "rectangle.and.hand.point.up.left.filled")
                    Text("\(wordsParsedToday.count)")
                        .foregroundColor(.accentColor)
                        .bold()
                    +
                    Text(" words") +
                    Text(" parsed")
                        .bold()
                    +
                    Text(" today")
                }
            }
        })
    }
    
    func NewWordsLearnedRow() -> some View {
        NavigationLink(value: Routes.newWords, label: {
            Group {
                HStack {
                    Image(systemName: "gift.fill")
                    Text("\(studySessionEntries.filter { $0.studyTypeInt == 0 }.count)")
                        .foregroundColor(.accentColor)
                        .bold()
                    +
                    Text(" new")
                        .bold()
                    +
                    Text(" words")
                    +
                    Text(" learned")
                        .bold()
                    +
                    Text(" today")
                }
            }
        })
    }
    
    func ReviewedWordsTodayRow() -> some View {
        Group {
            HStack {
                Image(systemName: "arrow.triangle.2.circlepath")
                Text("\(studySessionEntries.filter { $0.studyTypeInt == 1 }.count)")
                    .foregroundColor(.accentColor)
                    .bold()
                +
                Text(" previous")
                    .bold()
                +
                Text(" words")
                +
                Text(" reviewed")
                    .bold()
                +
                Text(" today")
            }
        }
    }
    
    func CurrentDueWordsRow() -> some View {
        NavigationLink(value: Routes.dueWords, label: {
            Group {
                HStack {
                    Image(systemName: "clock.badge.exclamationmark")
                    Text("\(dueVocabWords.count)")
                        .foregroundColor(.accentColor)
                        .bold()
                    +
                    Text(" words currently") +
                    Text(" due")
                        .bold()
                        .foregroundColor(.orange)
                }
            }
        })
        .isDetailLink(false)
        .navigationViewStyle(.stack)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
