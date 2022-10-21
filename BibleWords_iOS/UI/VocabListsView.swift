//
//  VocabListsView.swift
//  Bible_Words_iOS
//
//  Created by Shayne Torres on 10/11/22.
//

import SwiftUI

struct VocabListsView: View {
    enum Routes: Hashable {
        case showList(VocabWordList)
    }
    
    @Environment(\.managedObjectContext) var context
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VocabWordList.createdAt, ascending: true)],
        predicate: NSPredicate(format: "SELF.id != %@", "TEMP-DUE-WORD-LIST"),
        animation: .default)
    var lists: FetchedResults<VocabWordList>
    
    @State var showCreateListActionSheet = false
    @State var showCustomListBuilderView = false
    @State var showDefaultListSelectorView = false
    
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
//                    showCustomListBuilderView = true
                    showCreateListActionSheet = true
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
        .actionSheet(isPresented: $showCreateListActionSheet) {
            ActionSheet(
                title: Text("Create new vocab list"),
                message: Text("Would you like to create a custom vocab word list, or select a preset vocab list type?"), buttons: [
                    .cancel(),
                    .default(Text("Custom List")) {
                        showCustomListBuilderView = true
                    },
                    .default(Text("Preset List")) {
                        showDefaultListSelectorView = true
                    }
                ])
        }
        .sheet(isPresented: $showCustomListBuilderView) {
            NavigationStack {
                BuildVocabListView()
            }
        }
        .sheet(isPresented: $showDefaultListSelectorView) {
            NavigationStack {
                DefaultVocabListSelectorView()
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
        VocabListsView()
    }
}
