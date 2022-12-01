//
//  VocabListsView.swift
//  Bible_Words_iOS
//
//  Created by Shayne Torres on 10/11/22.
//

import SwiftUI
import CoreData

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
    
    @State var dueVocabWords: [VocabWord] = []
    
    @State var showCreateListActionSheet = false
    @State var showCreateBiblePassageListModal = false
    @State var showSelectDefaultListModal = false
    @State var showVocabListTypeInfoModal = false
    @State var showImportCSVFileView = false
    @State var showDueWords = false
    @State var showActivity = false
    @State var showSearch = false
    @State var showSettings = false
    
    @State var showPinnedVocab = true
    @State var showGreekVocab = true
    @State var showHebrewVocab = true
    @State var showImportedVocab = true
    
    var pinnedLists: [VocabWordList] {
        return lists.filter { $0.pin != nil }
    }

    var ntLists: [VocabWordList] {
        return lists.filter { !$0.rangesArr.isEmpty && $0.rangesArr.first?.bookStart.toInt ?? 0 >= 40 && $0.pin == nil }
    }
    
    var otLists: [VocabWordList] {
        return lists.filter { !$0.rangesArr.isEmpty && $0.rangesArr.first?.bookStart.toInt ?? 0 <= 39 && $0.pin == nil }
    }
    
    var importedLists: [VocabWordList] {
        return lists.filter { $0.rangesArr.isEmpty && $0.pin == nil }
    }
    
    var body: some View {
        NavigationView {
            List {
                if lists.isEmpty {
                    Text("It looks like you don't have any vocabulary lists yet. To Add one, tap the button at the bottom of the screen.")
                        .multilineTextAlignment(.center)
                        .appCard()
                        .padding(.horizontal)
                } else {
                    QuickActionsSection()
                    if !pinnedLists.isEmpty {
                        PinnedListsSetion()
                    }
                    if !ntLists.isEmpty {
                        NTListsSection()
                    }
                    if !otLists.isEmpty {
                        OTListsSection()
                    }
                    if !importedLists.isEmpty {
                        ImportedListsSection()                        
                    }
                }
            }
            .refreshable {
                refreshDueWords()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showSettings = true
                    }, label: {
                        Image(systemName: "gearshape.fill")
                    })
                    .labelStyle(.titleAndIcon)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showCreateListActionSheet = true
                    }, label: {
                        Image(systemName: "plus.circle")
                    })
                    .labelStyle(.titleAndIcon)
                }
            }
            .navigationTitle("Vocabulary")
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog("New Vocab List", isPresented: $showCreateListActionSheet, actions: {
                Button(action: {
                    showSelectDefaultListModal = true
                }, label: {
                    Text("Frequency List")
                })
                Button(action: {
                    showCreateBiblePassageListModal = true
                }, label: {
                    Text("Passage List")
                })
                Button(action: {
                    showImportCSVFileView = true
                }, label: {
                    Text("Import List")
                })
            }, message: {
                Text("What type of vocab list do you want to create?")
            })
            .sheet(isPresented: $showSettings) {
                NavigationView {
                    VocabSettingsView()
                }
            }
            .sheet(isPresented: $showActivity) {
                NavigationView {
                    StudyActivityView()
                }
            }
            .sheet(isPresented: $showSearch) {
                NavigationView {
                    SearchVocabWordsView()
                }
            }
            .sheet(isPresented: $showCreateBiblePassageListModal) {
                NavigationView {
                    BuildVocabListView()
                }
            }
            .sheet(isPresented: $showSelectDefaultListModal) {
                DefaultVocabListSelectorView()
            }
            .sheet(isPresented: $showVocabListTypeInfoModal) {
                VocabListTypeInfoView()
            }
            .sheet(isPresented: $showImportCSVFileView) {
                ImportCSVView()
            }
            .sheet(isPresented: $showDueWords) {
                NavigationView {
                    DueWordsView { due in
                        self.dueVocabWords = due
                    }
                }
            }
            .onAppear {
                refreshDueWords()
                setViews()
            }
        }.navigationViewStyle(.stack)
    }
    
    func refreshDueWords() {
        let vocabFetchRequest = NSFetchRequest<VocabWord>(entityName: "VocabWord")
        vocabFetchRequest.predicate = NSPredicate(format: "dueDate <= %@ && currentInterval > 0", Date() as CVarArg)
        var fetchedVocabWords: [VocabWord] = []
        do {
            fetchedVocabWords = try context.fetch(vocabFetchRequest)
        } catch let err {
            print(err)
        }
        
        dueVocabWords = fetchedVocabWords.filter { ($0.list?.count ?? 0) > 0 }
    }
    
    func setViews() {
        showGreekVocab = UserDefaultKey.vocabShowGreekLists.get(as: Bool.self)
        showHebrewVocab = UserDefaultKey.vocabShowHebrewLists.get(as: Bool.self)
        showImportedVocab = UserDefaultKey.vocabShowImportedLists.get(as: Bool.self)
    }
    
    func onDelete(_ list: VocabWordList) {
        CoreDataManager.transaction(context: context) {
            context.delete(list)
        }
    }
}

extension VocabListsView {
    
    @ViewBuilder
    func QuickActionsSection() -> some View {
        Section {
            HStack(alignment: .center) {
                Button(action: {
                    showActivity = true
                }, label: {
                    VStack(spacing: 4) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.title)
                        Text("Activity")
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .background(Color.accentColor)
                    .cornerRadius(12)
                })
                .buttonStyle(.borderless)
                .foregroundColor(.white)
                Button(action: {
                    showSearch = true
                }, label: {
                    VStack(spacing: 4) {
                        Image(systemName: "binoculars")
                            .font(.title)
                        Text("Search")
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .background(Color.accentColor)
                    .cornerRadius(12)
                })
                .buttonStyle(.borderless)
                .foregroundColor(.white)
                Button(action: {
                    showDueWords = true
                }, label: {
                    VStack(spacing: 4) {
                        Image(systemName: "clock.badge.exclamationmark")
                            .font(.title)
                        Text("\(dueVocabWords.count) words due")
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .background(Color.accentColor)
                    .cornerRadius(12)
                })
            }
            .buttonStyle(.borderless)
            .foregroundColor(.white)
        }
        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        .listRowBackground(Color.appBackground)
        .buttonStyle(.borderless)
    }
    
    @ViewBuilder
    func PinnedListsSetion() -> some View {
        Section {
            if showPinnedVocab {
                ForEach(pinnedLists) { list in
                    NavigationLink(destination: {
                        NavigationLazyView(ListDetailView(viewModel: .init(list: list)))
                    }) {
                        VocabWordListRow(list: list)
                    }
                    .contextMenu {
                        Button(role: .destructive, action: {
                            onDelete(list)
                        }, label: {
                            Label("Delete", systemImage: "trash")
                        })
                    }
                    .swipeActions {
                        Button(action: {
                            onDelete(list)
                        }, label: {
                            Text("Delete")
                        })
                        .tint(.red)
                    }
                }
            }
        } header: {
            HStack {
                Text("Pinned Vocab Lists")
                Spacer()
                Button(action: {
                    withAnimation {
                        showPinnedVocab.toggle()
                        UserDefaultKey.vocabPinnedLists.set(val: showPinnedVocab)
                    }
                }, label: {
                    Image(systemName: "chevron.up")
                        .rotationEffect(showPinnedVocab ? Angle(degrees: 0) : Angle(degrees: 180))
                })
            }
        }
    }
    
    @ViewBuilder
    func NTListsSection() -> some View {
        Section {
            if showGreekVocab {
                ForEach(ntLists) { list in
                    NavigationLink(destination: {
                        NavigationLazyView(ListDetailView(viewModel: .init(list: list)))
                    }) {
                        VocabWordListRow(list: list)
                    }
                    .contextMenu {
                        Button(role: .destructive, action: {
                            onDelete(list)
                        }, label: {
                            Label("Delete", systemImage: "trash")
                        })
                    }
                    .swipeActions {
                        Button(action: {
                            onDelete(list)
                        }, label: {
                            Text("Delete")
                        })
                        .tint(.red)
                    }
                }
            }
        } header: {
            HStack {
                Text("Greek Vocab")
                Spacer()
                Button(action: {
                    withAnimation {
                        showGreekVocab.toggle()
                        UserDefaultKey.vocabShowGreekLists.set(val: showGreekVocab)
                    }
                }, label: {
                    Image(systemName: "chevron.up")
                        .rotationEffect(showGreekVocab ? Angle(degrees: 0) : Angle(degrees: 180))
                })
            }
        }
    }
    
    @ViewBuilder
    func OTListsSection() -> some View {
        Section {
            if showHebrewVocab {
                ForEach(otLists) { list in
                    NavigationLink(destination: {
                        NavigationLazyView(ListDetailView(viewModel: .init(list: list)))
                    }) {
                        VocabWordListRow(list: list)
                    }
                    .contextMenu {
                        Button(role: .destructive, action: {
                            onDelete(list)
                        }, label: {
                            Label("Delete", systemImage: "trash")
                        })
                    }
                    .swipeActions {
                        Button(action: {
                            onDelete(list)
                        }, label: {
                            Text("Delete")
                        })
                    }
                }
            }
        } header: {
            HStack {
                Text("Hebrew Vocab")
                Spacer()
                Button(action: {
                    withAnimation {
                        showHebrewVocab.toggle()
                        UserDefaultKey.vocabShowHebrewLists.set(val: showHebrewVocab)
                    }
                }, label: {
                    Image(systemName: "chevron.up")
                        .rotationEffect(showHebrewVocab ? Angle(degrees: 0) : Angle(degrees: 180))
                })
            }
        }
    }
    
    @ViewBuilder
    func ImportedListsSection() -> some View {
        Section {
            if showImportedVocab {
                ForEach(importedLists) { list in
                    NavigationLink(destination: {
                        NavigationLazyView(ListDetailView(viewModel: .init(list: list)))
                    }) {
                        VocabWordListRow(list: list)
                    }
                    .contextMenu {
                        Button(role: .destructive, action: {
                            onDelete(list)
                        }, label: {
                            Label("Delete", systemImage: "trash")
                        })
                    }
                    .swipeActions {
                        Button(action: {
                            onDelete(list)
                        }, label: {
                            Text("Delete")
                        })
                    }
                }
            }
        } header: {
            HStack {
                Text("Imported Vocab")
                Spacer()
                Button(action: {
                    withAnimation {
                        showImportedVocab.toggle()
                        UserDefaultKey.vocabShowImportedLists.set(val: showImportedVocab)
                    }
                }, label: {
                    Image(systemName: "chevron.up")
                        .rotationEffect(showImportedVocab ? Angle(degrees: 0) : Angle(degrees: 180))
                })
            }
        }
    }
}

struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        VocabListsView()
    }
}
