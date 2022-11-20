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
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \StudySessionEntry.createdAt, ascending: false)],
        predicate: NSPredicate(format: "createdAt >= %@", Date.startOfToday as CVarArg)
    ) var studySessionEntries: FetchedResults<StudySessionEntry>
    
    @State var paths: [AppPath] = []
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
    
    var body: some View {
        NavigationStack(path: $paths) {
            List {
                if lists.isEmpty {
                    Text("It looks like you don't have any vocabulary lists yet. To Add one, tap the button at the bottom of the screen.")
                        .multilineTextAlignment(.center)
                        .appCard()
                        .padding(.horizontal)
                } else {
                    StatsCardSection()
                    ListsSection()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showStatsView = true
                    }, label: {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .fontWeight(.semibold)
                    })
                    .labelStyle(.titleAndIcon)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showCreateListActionSheet = true
                    }, label: {
                        Image(systemName: "plus.circle")
                            .fontWeight(.semibold)
                    })
                    .labelStyle(.titleAndIcon)
                }
            }
            .navigationTitle("Vocab Lists")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: AppPath.self) { path in
                switch path {
                case .vocabListDetail(let list, _):
                    ListDetailView(viewModel: .init(list: list))
                case .reviewedWords:
                    WordsSeenTodayView(entryType: .reviewedWord)
                case .newWords:
                    WordsSeenTodayView(entryType: .newWord)
                case .dueWords:
                    DueWordsView()
                case .wordInfo(let info):
                    WordInfoDetailsView(word: info.bound())
                case .wordInstance(let instance):
                    WordInPassageView(word: instance.wordInfo.bound(), instance: instance.bound())
                default:
                    Text("?")
                }
            }
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
            .sheet(isPresented: $showStatsView) {
                MoreStatsView()
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
            .sheet(isPresented: $showImportCSVFileView) {
                ImportCSVView()
            }
            .onAppear {
                refreshDueWords()
            }
            .refreshable {
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
                    paths.append(.reviewedWords)
                }, label: {
                    VStack(spacing: 4) {
                        Text("Reviewed")
                            .font(.footnote)
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.title)
                        Text("\(studySessionEntries.filter { $0.studyTypeInt == 1 }.count)")
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                })
                .buttonStyle(.borderless)
                Button(action: {
                    paths.append(.newWords)
                }, label: {
                    VStack(spacing: 4) {
                        Text("New")
                            .font(.footnote)
                        Image(systemName: "gift")
                            .font(.title)
                        Text("\(studySessionEntries.filter { $0.studyTypeInt == 0 }.count)")
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                })
                .buttonStyle(.borderless)
                Button(action: {
                    paths.append(.dueWords)
                }, label: {
                    VStack(spacing: 4) {
                        Text("Due")
                            .font(.footnote)
                        Image(systemName: "clock.badge.exclamationmark")
                            .font(.title)
                        Text("\(dueVocabWords.count)")
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                })
            }
            .buttonStyle(.borderless)
        }
        .listRowBackground(Color.accentColor)
        .foregroundColor(.white)
    }
    
    @ViewBuilder
    func ListsSection() -> some View {
        ForEach(lists) { list in
            NavigationLink(value: AppPath.vocabListDetail(list: list, autoStudy: false)) {
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
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        VocabListsView()
    }
}
