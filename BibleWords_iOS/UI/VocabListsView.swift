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
    @State var showCreateBiblePassageListModal = false
    @State var showSelectDefaultListModal = false
    @State var showCreateCustomListModal = false
    @State var showStatsInfoModal = false
    @State var showVocabListTypeInfoModal = false
    
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
                            NavigationLink(value: AppPath.vocabListDetail(list: list, autoStudy: false)) {
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
                AppButton(text: "Create new list") {
                    showCreateListActionSheet = true
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .navigationTitle("Vocab Lists")
        .actionSheet(isPresented: $showCreateListActionSheet) {
            ActionSheet(
                title: Text("Create new vocab list"),
                message: Text("What type of vocab list would you like to create?"), buttons: [
                    .cancel(),
                    .default(Text("Bible Passage(s) List")) {
                        showCreateBiblePassageListModal = true
                    },
                    .default(Text("Default List")) {
                        showSelectDefaultListModal = true
                    },
                    .default(Text("Custom Word List")) {
                        showCreateCustomListModal = true
                    },
                    .default(Text("What are these?")) {
                        showVocabListTypeInfoModal = true
                    }
                ])
        }
        .sheet(isPresented: $showCreateBiblePassageListModal) {
            NavigationStack {
                BuildVocabListView()
            }
        }
        .sheet(isPresented: $showSelectDefaultListModal) {
            NavigationStack {
                DefaultVocabListSelectorView()
            }
        }
        .sheet(isPresented: $showCreateCustomListModal) {
            CustomWordListBuilderView(viewModel: .init(list: nil))
        }
        .sheet(isPresented: $showVocabListTypeInfoModal) {
            VocabListTypeInfoView()
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
