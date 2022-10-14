//
//  MainView.swift
//  Bible_Words_iOS
//
//  Created by Shayne Torres on 10/11/22.
//

import SwiftUI

struct MainView: View {
    enum Routes: Hashable {
        case showList(WordList)
    }
    
    @Environment(\.managedObjectContext) var context
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WordList.createdAt, ascending: true)],
        animation: .default)
    var lists: FetchedResults<WordList>
    
    @State var showListBuilderView = false
    
    var body: some View {
        ZStack {
            if lists.isEmpty {
                List {
                    Text("It looks like you don't have any vocabulary lists yet. To Add one, tap the button at the bottom of the screen.")
                        .multilineTextAlignment(.center)
                }
            } else {
                List(lists) { list in
                    HStack {
                        NavigationLink(value: Routes.showList(list)) {
                            HStack {
                                Text(list.defaultTitle)
                                Spacer()
                                Text(list.defaultDetails)
                            }
                        }
                    }
                        .swipeActions {
                            Button(action: {
                                withAnimation {
                                    onDelete(list)
                                }
                            }, label: { Text("Delete") })
                            .tint(.red)
                        }
                }
            }
            VStack {
                Spacer()
                Button(action: {
                    showListBuilderView = true
                }, label: {
                    Text("Create new list")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .bold()
                        .cornerRadius(10)
                        .padding()
                })
            }
        }
        .navigationTitle("Vocab Lists")
        .navigationDestination(for: Routes.self) { r in
            switch r {
            case .showList(let list):
                ListDetailView(viewModel: .init(list: list))
            }
        }
        .sheet(isPresented: $showListBuilderView) {
            NavigationStack {
                BuildVocabListView()
            }
        }
        .onAppear {
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            } else {
                fetchData()
            }
        }
    }
    
    func fetchData() {
        Task {
            await API.main.fetchHebrewDict()
            await API.main.fetchHebrewBible()
            await API.main.fetchGreekDict()
            await API.main.fetchGreekBible()
            API.main.dataReadyPublisher.send(true)
        }
    }
    
    func onDelete(_ list: WordList) {
        CoreDataManager.transaction(context: context) {
            context.delete(list)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
