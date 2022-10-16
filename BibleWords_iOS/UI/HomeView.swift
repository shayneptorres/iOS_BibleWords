//
//  HomeView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/14/22.
//

import SwiftUI

struct HomeView: View {
    enum Routes: Hashable {
        case allLists
        case showList(VocabWordList)
        case paradigms(VocabWord.Language)
        case dueWords
    }
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VocabWord.createdAt, ascending: true)],
        animation: .default)
    var words: FetchedResults<VocabWord>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VocabWordList.createdAt, ascending: true)],
        predicate: NSPredicate(format: "SELF.id != %@", "TEMP-DUE-WORD-LIST"),
        animation: .default)
    var lists: FetchedResults<VocabWordList>
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Group {
                        HStack {
                            Image(systemName: "book")
                            Text("\(123)")
                                .foregroundColor(.accentColor)
                                .bold()
                            +
                            Text(" words") +
                            Text(" studied")
                                .bold()
                            +
                            Text(" today")
                        }
                    }
                    Group {
                        HStack {
                            Image(systemName: "stopwatch")
                            Text("\(123)")
                                .foregroundColor(.accentColor)
                                .bold()
                            +
                            Text(" minutes") +
                            Text(" studied")
                                .bold()
                            +
                            Text(" today")
                        }
                    }
                    NavigationLink(value: Routes.dueWords, label: {
                        Group {
                            HStack {
                                Image(systemName: "clock.badge.exclamationmark")
                                Text("\(dueVocabWords.count)")
                                    .foregroundColor(.accentColor)
                                    .bold()
                                +
                                Text(" words") +
                                Text(" due")
                                    .bold()
                                    .foregroundColor(.orange)
                            }
                        }
                    })
                    .isDetailLink(false)
                    .navigationViewStyle(.stack)
                } header: {
                    Text("Stats")
                }
                Section {
                    if recentlyStudiedLists.isEmpty {
                        Text("Oh no! You haven't studied any vocab lists yet! You should do something about that")
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
                    NavigationLink("All lists", value: Routes.allLists)
                        .bold()
                        .foregroundColor(.accentColor)
                } header: {
                    Text("Your lists")
                }
                
                Section {
                    NavigationLink("Hebrew Paradigms", value: Routes.paradigms(.hebrew))
                        .bold()
                        .foregroundColor(.accentColor)
                    NavigationLink("Greek Paradigms", value: Routes.paradigms(.greek))
                        .bold()
                        .foregroundColor(.accentColor)
                } header: {
                    Text("Paradigm Practice")
                }
            }
            .navigationTitle("Bible Words")
            .navigationDestination(for: Routes.self) { route in
                switch route {
                case .allLists:
                    MainView()
                case .showList(let list):
                    ListDetailView(viewModel: .init(list: list))
                case .paradigms(let lang):
                    switch lang {
                    case .greek:
                        Text("TODO")
                    case .hebrew, .aramaic:
                        ParadigmsViews()
                    }
                case .dueWords:
                    DueWordsView()
                }
            }
            .onAppear {
                if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                } else {
                    fetchData()
                }
            }
        }
    }
    
    var dueVocabWords: [VocabWord] {
        words.filter { $0.isDue }
    }
    
    var recentlyStudiedLists: [VocabWordList] {
        let recent = lists
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
