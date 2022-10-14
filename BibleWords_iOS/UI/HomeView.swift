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
    }
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VocabWord.createdAt, ascending: true)],
        animation: .default)
    var words: FetchedResults<VocabWord>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VocabWordList.createdAt, ascending: true)],
        animation: .default)
    var lists: FetchedResults<VocabWordList>
    
    var body: some View {
        NavigationStack {
            List {
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
                } header: {
                    Text("Recently Studied Lists")
                }
                
                Section {
                    NavigationLink("Hebrew Paradigms", value: Routes.paradigms(.hebrew))
                    NavigationLink("Greek Paradigms", value: Routes.paradigms(.greek))
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
    
    var recentlyStudiedLists: [VocabWordList] {
        print(lists.count)
        let recent = lists
            .sorted { $0.lastStudied ?? Date().addingTimeInterval(-Double(7.days)) > $1.lastStudied ?? Date().addingTimeInterval(-Double(7.days)) }
        
        return Array(recent.prefix(4))
    }
    
    func fetchData() {
        Task {
            guard !API.main.coreDataReadyPublisher.value else { return }
            await API.main.fetchHebrewDict()
            await API.main.fetchHebrewBible()
            await API.main.fetchGreekDict()
            await API.main.fetchGreekBible()
            API.main.coreDataReadyPublisher.send(true)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
