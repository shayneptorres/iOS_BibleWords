//
//  MainView.swift
//  Bible_Words_iOS
//
//  Created by Shayne Torres on 10/11/22.
//

import SwiftUI

struct MainView: View {
    enum Routes: Hashable {
        case showList(VocabWordList)
    }
    
    @Environment(\.managedObjectContext) var context
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VocabWordList.createdAt, ascending: true)],
        animation: .default)
    var lists: FetchedResults<VocabWordList>
    
    @State var showListBuilderView = false
    
    var body: some View {
        ZStack {
            if lists.isEmpty {
                List {
                    Text("It looks like you don't have any vocabulary lists yet. To Add one, tap the button at the bottom of the screen.")
                        .multilineTextAlignment(.center)
                }
            } else {
                List {
                    ForEach(lists) { list in
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
    }
    
    func onDelete(_ list: VocabWordList) {
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
