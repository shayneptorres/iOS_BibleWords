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
    @State var showStatsView  = false
    @State var showCreateBiblePassageListModal = false
    @State var showSelectDefaultListModal = false
    @State var showCreateCustomListModal = false
    @State var showStatsInfoModal = false
    @State var showVocabListTypeInfoModal = false
    @State var showCreateListPickerSection = false
    @State var showImportCSVFileView = false
    @State var showReviewedWords = false
    @State var showNewWords = false
    @State var showDueWords = false
    @State var showActivity = false
    @State var showSettings = false

    var ntLists: [VocabWordList] {
        return lists.filter { !$0.rangesArr.isEmpty && $0.rangesArr.first?.bookStart.toInt ?? 0 >= 40 }
    }
    
    var otLists: [VocabWordList] {
        return lists.filter { !$0.rangesArr.isEmpty && $0.rangesArr.first?.bookStart.toInt ?? 0 <= 39 }
    }
    
    var importedLists: [VocabWordList] {
        return lists.filter { $0.rangesArr.isEmpty }
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
                    StatsCardSection()
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
            .sheet(isPresented: $showStatsView) {
                MoreStatsView()
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
                    DueWordsView()
                }
            }
            .onAppear {
                refreshDueWords()
            }
        }
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
    func StatsCardSection() -> some View {
        Section {
            HStack(alignment: .center) {
                Button(action: {
                    showActivity = true
                }, label: {
                    VStack(spacing: 4) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.title)
                        Text("Activity")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
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
                        Text("Due Words")
//                            .font(.footnote)
//                        Text("\(dueVocabWords.count)")
//                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
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
    func NTListsSection() -> some View {
        Section {
            ForEach(ntLists) { list in
                NavigationLink(destination: {
                    NavigationLazyView(ListDetailView(viewModel: .init(list: list)))
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(list.defaultTitle)
                            .bold()
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.accentColor)
                        Text(list.defaultDetails)
                            .font(.caption)
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                    }
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
        } header: {
            Text("Greek Vocab")
        }
    }
    
    @ViewBuilder
    func OTListsSection() -> some View {
        Section {
            ForEach(otLists) { list in
                NavigationLink(destination: {
                    NavigationLazyView(ListDetailView(viewModel: .init(list: list)))
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(list.defaultTitle)
                            .bold()
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.accentColor)
                        Text(list.defaultDetails)
                            .font(.caption)
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                    }
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
        } header: {
            Text("Hebrew Vocab")
        }
    }
    
    @ViewBuilder
    func ImportedListsSection() -> some View {
        Section {
            ForEach(importedLists) { list in
                NavigationLink(destination: {
                    NavigationLazyView(ListDetailView(viewModel: .init(list: list)))
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(list.defaultTitle)
                            .bold()
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.accentColor)
                        Text(list.defaultDetails)
                            .font(.caption)
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                    }
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
        } header: {
            Text("Imported Vocab")
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
