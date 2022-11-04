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
    @State var showCreateListPickerSection = false
    @State var showImportCSVFileView = false
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            ScrollView {
                if lists.isEmpty {
                    Text("It looks like you don't have any vocabulary lists yet. To Add one, tap the button at the bottom of the screen.")
                        .multilineTextAlignment(.center)
                        .appCard()
                        .padding(.horizontal)
                } else {
                    ListsSection()
                }
            }
            VStack {
                Spacer()
                if showCreateListPickerSection {
                    CreateListButtonsSection()
                        .transition(.move(edge: .trailing))
                } else {
                    AppButton(text: "Create new list") {
                        withAnimation {
                            showCreateListPickerSection = true
                        }
                    }
                    .transition(.move(edge: .leading))
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
        }
        .navigationTitle("Vocab Lists")
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
        .sheet(isPresented: $showImportCSVFileView) {
            ImportCSVView()
        }
    }
    
    func onDelete(_ list: VocabWordList) {
        CoreDataManager.transaction(context: context) {
            context.delete(list)
        }
    }
}

extension VocabListsView {
    @ViewBuilder
    func CreateListButtonsSection() -> some View {
        VStack(spacing: 8) {
            HStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        showVocabListTypeInfoModal = true
                    }
                }, label: {
                    Image(systemName: "questionmark.circle")
                        .font(.title)
                })
                Spacer()
                Button(action: {
                    withAnimation {
                        showCreateListPickerSection = false
                    }
                }, label: {
                    Image(systemName: "xmark.circle")
                        .font(.title)
                })
                Spacer()
            }
            HStack {
                Button(action: {
                    withAnimation {
                        showCreateBiblePassageListModal = true
                        showCreateListPickerSection = false
                    }
                }, label: {
                    VStack {
                        Image(systemName: "text.book.closed.fill")
                            .font(.title2)
                            .padding(.bottom, 4)
                        Text("Passage\nList")
                            .font(.caption2)
                    }
                    .foregroundColor(.accentColor)
                    .appCard(height: 60, innerPadding: 8)
                })
                Button(action: {
                    withAnimation {
                        showSelectDefaultListModal = true
                        showCreateListPickerSection = false
                    }
                }, label: {
                    VStack {
                        Image(systemName: "list.bullet.rectangle.portrait.fill")
                            .font(.title2)
                            .padding(.bottom, 4)
                        Text("Default\nList")
                            .font(.caption2)
                    }
                    .foregroundColor(.accentColor)
                    .appCard(height: 60, innerPadding: 8)
                })
                Button(action: {
                    withAnimation {
                        showImportCSVFileView = true
                        showCreateListPickerSection = false
                    }
                }, label: {
                    VStack {
                        Image(systemName: "arrow.down.doc")
                            .font(.title2)
                            .padding(.bottom, 4)
                        Text("Import\nList")
                            .font(.caption2)
                    }
                    .foregroundColor(.accentColor)
                    .appCard(height: 60, innerPadding: 8)
                })
            }
        }
        .padding(.horizontal, Design.viewHorziontalPadding)
    }
    
    @ViewBuilder
    func ListsSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(lists) { list in
                NavigationLink(value: AppPath.vocabListDetail(list: list, autoStudy: false)) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(list.defaultTitle)
                                .bold()
                                .multilineTextAlignment(.leading)
                            Text(list.defaultDetails)
                                .font(.caption)
                                .foregroundColor(Color(uiColor: .secondaryLabel))
                        }
                        Spacer()
                        Image(systemName: "arrow.forward.circle")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                    }
                }
                .appCard(outerPadding: 0)
                .contextMenu {
                    Button(role: .destructive, action: {
                        onDelete(list)
                    }, label: {
                        Label("Delete", systemImage: "trash")
                    })
                }
            }
        }
        .padding(.horizontal, Design.viewHorziontalPadding)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        VocabListsView()
    }
}
