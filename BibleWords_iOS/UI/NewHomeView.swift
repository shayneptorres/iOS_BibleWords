//
//  NewHomeView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/21/22.
//

import SwiftUI
import CoreData
import WidgetKit
import ActivityKit

enum AppPath: Hashable {
    case reviewedWords
    case newWords
    case parsedWords
    case dueWords
    case selectedWords
    case allVocabLists
    case vocabListDetail(list: VocabWordList, autoStudy: Bool)
    case wordInfoList(wordInfos: [Bible.WordInfo], viewTitle: String)
    case wordInstanceList([Bible.WordInstance])
    case allParsingLists
    case parsingListDetail(ParsingList)
    case greekParadigms
    case hebrewParadigms
    case wordInfo(Bible.WordInfo)
    case wordInstance(Bible.WordInstance)
    case parsingSessionsList(ParsingList)
    case parsingSessionDetail(StudySession)
}

struct NewHomeView: View {
    
    // MARK: Environment
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    // MARK: Fetch Requests
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \StudySession.endDate, ascending: false)],
        predicate: NSPredicate(format: "endDate >= %@", Date.startOfToday as CVarArg)
    ) var sessions: FetchedResults<StudySession>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \StudySessionEntry.createdAt, ascending: false)],
        predicate: NSPredicate(format: "createdAt >= %@", Date.startOfToday as CVarArg)
    ) var studySessionEntries: FetchedResults<StudySessionEntry>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VocabWordList.createdAt, ascending: true)],
        predicate: NSPredicate(format: "SELF.id != %@", "TEMP-DUE-WORD-LIST"),
        animation: .default)
    var vocabLists: FetchedResults<VocabWordList>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VocabWordList.createdAt, ascending: true)],
        animation: .default)
    var parsingLists: FetchedResults<ParsingList>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VocabWordList.createdAt, ascending: true)],
        predicate: NSPredicate(format: "SELF.id == %@", "TEMP-DUE-WORD-LIST"),
        animation: .default)
    var dueVocabLists: FetchedResults<VocabWordList>
    var dueList: VocabWordList? {
        return dueVocabLists.first
    }
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VocabWord.dueDate, ascending: false)],
        predicate: NSPredicate(format: "dueDate <= %@ && currentInterval > 0", Date() as CVarArg)
    ) var dueWords: FetchedResults<VocabWord>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PinnedItem.createdAt, ascending: false)]
    ) var pins: FetchedResults<PinnedItem>
    
    @StateObject var viewModel = DataDependentViewModel()
    
    // MARK: Namespace
    @Namespace var homeViewNamepace
    
    // MARK: State
    @State var paths: [AppPath] = []
    @State var showFullStats = false
    @State var showFullPins = false
    @State var showFullRecent = false
    @State var showStatsInfoModal = false
    @State var showMoreStatsModal = false
    @State var showCreateListActionSheet = false
    @State var showCreateBiblePassageListModal = false
    @State var showCreateParsingModal = false
    @State var showSelectDefaultListModal = false
    @State var showCreateCustomListModal = false
    @State var showBibleReadingView = false
    @State var showVocabListTypeInfoModal = false
    
    // MARK: UI Constants
    let horizontalPadding: CGFloat = 12
    
    var body: some View {
        NavigationStack(path: $paths) {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                if horizontalSizeClass == .regular {
                    HStack {
                        VStack {
                            ScrollView {
                                if viewModel.isBuilding {
                                    DataIsBuildingCard(rotationAngle: $viewModel.animationRotationAngle)
                                        .transition(.move(edge: .leading))
                                        .padding(.horizontal, Design.viewHorziontalPadding)
                                }
                                StatsCardView()
                                QuickActionsSection()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        VStack {
                            ScrollView {
                                PinnedItemsSection()
                                RecentActivitySection()
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                } else {
                    ScrollView {
                        if viewModel.isBuilding {
                            DataIsBuildingCard(rotationAngle: $viewModel.animationRotationAngle)
                                .transition(.move(edge: .trailing))
                                .padding(.horizontal, Design.viewHorziontalPadding)
                        }
                        StatsCardView()
                        QuickActionsSection()
                        PinnedItemsSection()
                        RecentActivitySection()
                    }
                }
            }
            .navigationTitle("Bible Words")
            .navigationDestination(for: AppPath.self) { path in
                switch path {
                case .reviewedWords:
                    WordsSeenTodayView(entryType: .reviewedWord)
                case .newWords:
                    WordsSeenTodayView(entryType: .newWord)
                case .parsedWords:
                    WordsSeenTodayView(entryType: .parsing)
                case .dueWords:
                    if let list = dueList {
                        DueWordsView(viewModel: .init(list: list))
                    } else {
                        Text("Something went wrong")
                    }
                case .allVocabLists:
                    VocabListsView()
                case .vocabListDetail(let list, let autoStudy):
                    ListDetailView(viewModel: .init(list: list, autoStudy: autoStudy))
                case .wordInfoList(let words, let viewTitle):
                    List(words.sorted { $0.lemma.lowercased() < $1.lemma.lowercased() }) { word in
                        NavigationLink(value: AppPath.wordInfo(word)) {
                            WordInfoRow(wordInfo: word.bound())
                        }
                    }.navigationBarTitle(viewTitle)
                case .wordInstanceList(let instances):
                    List {
                        Section {
                            ForEach(instances) { instance in
                                VStack(alignment: .leading) {
                                    Text(instance.textSurface)
                                        .font(instance.language.meduimBibleFont)
                                        .padding(.bottom, 4)
                                    Text(instance.parsingStr)
                                        .font(.subheadline)
                                        .foregroundColor(Color(uiColor: .secondaryLabel))
                                }
                            }
                        } header: {
                            Text("Forms")
                        }
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .principal) {
                            Text(instances.first?.lemma ?? "").font(.bible24)
                        }
                    }
                case .allParsingLists:
                    ParsingListsView()
                case .parsingListDetail(let list):
                    ParsingListDetailView(viewModel: .init(list: list))
                case .parsingSessionsList(let list):
                    ParsingListSessionsView(list: list.bound())
                case .parsingSessionDetail(let session):
                    List {
                        ForEach(session.entriesArr.sorted { $0.createdAt! < $1.createdAt! }) { entry in
                            ParsingSessionEntryRow(entry: entry.bound())
                        }
                    }
                case .greekParadigms:
                    Text("Coming soon...")
                case .hebrewParadigms:
                    ConceptsView()
                case .wordInfo(let info):
                    WordInfoDetailsView(word: info)
                case .wordInstance(let instance):
                    WordInPassageView(word: instance.wordInfo.bound(), instance: instance.bound())
                default:
                    Text("Not implemented")
                }
            }
        }
        .fullScreenCover(isPresented: $showBibleReadingView) {
            NavigationStack {
                BibleReadingView()
            }
        }
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
        .sheet(isPresented: $showMoreStatsModal) {
            MoreStatsView()
        }
        .sheet(isPresented: $showStatsInfoModal) {
            NavigationStack {
                StatsInfoModal()
            }
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
        .sheet(isPresented: $showCreateParsingModal) {
            NavigationStack {
                BuildParsingListView()
            }
        }
        .sheet(isPresented: $showCreateCustomListModal) {
            CustomWordListBuilderView(viewModel: .init(list: nil))
                .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showVocabListTypeInfoModal) {
            VocabListTypeInfoView()
        }
        .onAppear {
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            } else {
                fetchData()
                initCoreData()
                initUI()
            }
            if #available(iOS 16.1, *) {
                if !Activity<StudyAttributes>.activities.isEmpty {
                    for activity in Activity<StudyAttributes>.activities {
                        Task {
                            await activity.end(dismissalPolicy: .immediate)
                        }
                    }
                }                
            }
            
//            CoreDataManager.transaction(context: context) {
//                let deleteFetchRequest = NSFetchRequest<PinnedItem>(entityName: "PinnedItem")
//                
//                var pins: [PinnedItem] = []
//                do {
//                    pins = try context.fetch(deleteFetchRequest)
//                } catch let err {
//                    print(err)
//                }
//                
//                for pin in pins {
//                    context.delete(pin)
//                }
//            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                print("Active")
            } else if newPhase == .inactive {
                print("Inactive")
            } else if newPhase == .background {
                print("Background")
                AppGroupManager.updateStats(context)
            }
        }
    }
}

// MARK: Data Methods
extension NewHomeView {
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
    
    func initCoreData() {
        if dueVocabLists.first == nil {
            CoreDataManager.transactionAsync(context: context) {
                let dueWordsList = VocabWordList(context: context)
                dueWordsList.id = "TEMP-DUE-WORD-LIST"
                dueWordsList.title = "Your Due Words"
                dueWordsList.details = "A temporary vocab list to handle the words that are currently due, regardless of their list"
                dueWordsList.lastStudied = Date()
                dueWordsList.createdAt = Date()
            }
        }
    }
    
    func initUI() {
        showFullStats = UserDefaultKey.homeViewShowFullStats.get(as: Bool.self)
        showFullPins = UserDefaultKey.homeViewShowFullPins.get(as: Bool.self)
        showFullRecent = UserDefaultKey.homeViewShowFullRecents.get(as: Bool.self)
    }
    
    func getWidgetTimelineData() {
        
    }
}

extension NewHomeView {
    @ViewBuilder
    func StatsCardView() -> some View {
        VStack {
            if showFullStats {
                HStack(alignment: .firstTextBaseline) {
                    Text("Today's Stats")
                        .font(.title2)
                        .bold()
                        .transition(.opacity)
                    Button(action: {
                        showStatsInfoModal = true
                    }, label: {
                        Image(systemName: "info.circle")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                    })
                    Spacer()
                    Button(action: {
                        withAnimation {
                            showFullStats.toggle()
                            UserDefaultKey.homeViewShowFullStats.set(val: showFullStats)
                        }
                    }, label: {
                        Image(systemName: "chevron.up")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                    })
                    .matchedGeometryEffect(id: "home.stats.chevron-button", in: homeViewNamepace)
                }
                .matchedGeometryEffect(id: "home.stats.top-container", in: homeViewNamepace)
                Divider()
            }
            HStack(alignment: .center) {
                Button(action: {
                    paths.append(.reviewedWords)
                }, label: {
                    VStack(spacing: 4) {
                        if showFullStats {
                            Spacer()
                            Text("Reviewed")
                                .font(.footnote)
                                .foregroundColor(.accentColor)
                        }
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                        Text("\(studySessionEntries.filter { $0.studyTypeInt == 1 }.count)")
                            .font(showFullStats ? .body : .subheadline)
                            .foregroundColor(Color(uiColor: .label))
                        if showFullStats {
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity)
                })
                Button(action: {
                    paths.append(.newWords)
                }, label: {
                    VStack(spacing: 4) {
                        if showFullStats {
                            Spacer()
                            Text("New")
                                .font(.footnote)
                                .foregroundColor(.accentColor)
                        }
                        Image(systemName: "gift")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                        Text("\(studySessionEntries.filter { $0.studyTypeInt == 0 }.count)")
                            .font(showFullStats ? .body : .subheadline)
                            .foregroundColor(Color(uiColor: .label))
                        if showFullStats {
                            Spacer()
                        }
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                })
                Button(action: {
                    paths.append(.parsedWords)
                }, label: {
                    VStack(spacing: 4) {
                        if showFullStats {
                            Spacer()
                            Text("Parsed")
                                .font(.footnote)
                                .foregroundColor(.accentColor)
                        }
                        Image(systemName: "rectangle.and.hand.point.up.left.filled")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                        Text("\(studySessionEntries.filter { $0.studyTypeInt == 2 }.count)")
                            .font(showFullStats ? .body : .subheadline)
                            .foregroundColor(Color(uiColor: .label))
                        if showFullStats {
                            Spacer()
                        }
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                })
                Button(action: {
                    paths.append(.dueWords)
                }, label: {
                    VStack(spacing: 4) {
                        if showFullStats {
                            Spacer()
                            Text("Due")
                                .font(.footnote)
                                .foregroundColor(.accentColor)
                        }
                        Image(systemName: "clock.badge.exclamationmark")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                        Text("\(dueWords.filter { ($0.list?.count ?? 0) > 0 }.count)")
                            .font(showFullStats ? .body : .subheadline)
                            .foregroundColor(Color(uiColor: .label))
                        if showFullStats {
                            Spacer()
                        }
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                })
                if !showFullStats {
                    Button(action: {
                        withAnimation {
                            showFullStats.toggle()
                            UserDefaultKey.homeViewShowFullStats.set(val: showFullStats)
                        }
                    }, label: {
                        Image(systemName: "chevron.down")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    })
                    .matchedGeometryEffect(id: "home.stats.chevron-button", in: homeViewNamepace)
                }
            }
            .padding(.top, 4)
            if showFullStats {
                Divider()
                    .padding(.top, 4)
                HStack {
                    Button(action: {
                        showMoreStatsModal = true
                    }, label: {
                        Text("More Stats")
                            .foregroundColor(.accentColor)
                            .font(.headline)
                            .bold()
                            .transition(.opacity)
                    })
                }
                .padding(.top, 4)
            }
        }
        .appCard()
        .padding(.horizontal, Design.viewHorziontalPadding)
    }
    
    @ViewBuilder
    func StatsInfoModal() -> some View {
        List {
            Section {
                VStack(alignment: .leading) {
                    Text("What do those images and numbers mean?")
                        .font(.headline)
                        .padding(.bottom, 4)
                    Text("Tap any of the icons on the home screen to see more information")
                        .font(.subheadline)
                }
            }
            Section {
                InfoImageTextRow(imageName: "arrow.triangle.2.circlepath", text: "This represents the vocab words that you have previously learned but have reviewed today. Every day this will be set to 0 and the count will increase as you review previous vocab words")
                InfoImageTextRow(imageName: "gift", text: "This represents the new words that you were exposed to today. Once exposed, they are given a due date and you will see them later. At that point they will become 'reviewed' words.")
                InfoImageTextRow(imageName: "rectangle.and.hand.point.up.left.filled", text: "This represents the number of words that you have parsed today. Learning biblical greek and hebrew is more than just vocabulary. Make sure to spend time practicing your parsing.")
                InfoImageTextRow(imageName: "clock.badge.exclamationmark", text: "This represents the number of vocab words that are past due. You have already seen these words before and it is time for you to review them again")                
            }
        }
        .toolbar {
            Button(action: { showStatsInfoModal = false }, label: {
                Text("Dismiss")
                    .bold()
            })
        }
        .navigationTitle("App Statistics")
    }
    
    @ViewBuilder
    func QuickActionsSection() -> some View {
        HStack {
            Button(action: {
                showBibleReadingView = true
            }, label: {
                VStack(spacing: 8) {
                    Image(systemName: "book")
                        .font(.title2)
                    Text("Bible")
                        .font(.caption2)
                        .bold()
                }
                .appCard(height: 60, innerPadding: 8)
            })
            Button(action: {
                paths.append(.allVocabLists)
            }, label: {
                VStack(spacing: 8) {
                    Image(systemName: ActivityType.vocab.imageName)
                        .font(.title2)
                    Text("Vocab")
                        .font(.caption2)
                        .bold()
                }
                .appCard(height: 60, innerPadding: 8)
            })
            Button(action: {
                paths.append(.allParsingLists)
            }, label: {
                VStack(spacing: 8) {
                    Image(systemName: ActivityType.parsing.imageName)
                        .font(.title2)
                    Text("Parsing")
                        .font(.caption2)
                        .bold()
                }
                    .appCard(height: 60, innerPadding: 8)
            })
            Button(action: {
                paths.append(.hebrewParadigms)
            }, label: {
                VStack(spacing: 8) {
                    Image(systemName: ActivityType.paradigm.imageName)
                        .font(.title2)
                    Text("Paradigm")
                        .font(.caption2)
                        .bold()
                }
                    .appCard(height: 60, innerPadding: 4)
            })
        }
        .padding(.horizontal, Design.viewHorziontalPadding)
    }
    
    @ViewBuilder
    func PinnedItemsSection() -> some View {
        VStack {
            if showFullPins {
                HStack(alignment: .firstTextBaseline) {
                    Image(systemName: "pin.fill")
                        .matchedGeometryEffect(id: "home.pins.pin-image", in: homeViewNamepace)
                        .font(.headline)
                        .foregroundColor(.appOrange)
                    Text("Pinned Items")
                        .font(.headline)
                        .bold()
                        .transition(.opacity)
                    Spacer()
                    Button(action: {
                        withAnimation {
                            showFullPins.toggle()
                            UserDefaultKey.homeViewShowFullPins.set(val: showFullPins)
                        }
                    }, label: {
                        Image(systemName: "chevron.up")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                    })
                    .matchedGeometryEffect(id: "home.pins.chevron", in: homeViewNamepace)
                }
                Divider()
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(pins) { pin in
                        PinnedItemRow(pin: pin)
                            .padding(.leading, 8)
                    }
                }
                .padding(.top, 8)
            } else {
                HStack {
                    Image(systemName: "pin.fill")
                        .matchedGeometryEffect(id: "home.pins.pin-image", in: homeViewNamepace)
                        .font(.headline)
                        .foregroundColor(.appOrange)
                    HStack(spacing: 20) {
                        ForEach(pins.prefix(5)) { pin in
                            ZStack {
                                Image(systemName: pin.activityType.imageName)
                                    .font(.title2)
                                    .foregroundColor(.accentColor)
                                VStack {
                                    HStack {
                                        Spacer()
                                        Image(systemName: "pin.fill")
                                            .font(.footnote)
                                            .foregroundColor(.appOrange)
                                            .padding(.trailing, 2)
                                    }
                                    Spacer()
                                }
                            }
                            .matchedGeometryEffect(id: "pin-row.image.\(pin.id ?? "")", in: homeViewNamepace)
                            .frame(width: 30)
                            .onTapGesture {
                                onTap(pin: pin)
                            }
                        }
                    }
                    Spacer()
                    Button(action: {
                        withAnimation {
                            showFullPins.toggle()
                            UserDefaultKey.homeViewShowFullPins.set(val: showFullPins)
                        }
                    }, label: {
                        Image(systemName: "chevron.down")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                    })
                    .matchedGeometryEffect(id: "home.pins.chevron", in: homeViewNamepace)
                }
            }
        }
        .appCard()
        .padding(.horizontal, Design.viewHorziontalPadding)
    }
    
    @ViewBuilder
    func PinnedItemRow(pin: PinnedItem) -> some View {
        HStack(alignment: .center) {
            ZStack {
                Image(systemName: pin.activityType.imageName)
                    .font(.largeTitle)
                    .foregroundColor(.accentColor)
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "pin.fill")
                            .font(.subheadline)
                            .foregroundColor(.appOrange)
                            .padding(.trailing, 4)
                    }
                    Spacer()
                }
            }
            .matchedGeometryEffect(id: "pin-row.image.\(pin.id ?? "")", in: homeViewNamepace)
            .frame(width: 30)
            .padding(.trailing, 8)
            VStack(alignment: .leading) {
                Text(pin.activityType.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(pin.pinTitle ?? "")
                    .font(.subheadline)
                    .fontWeight(.regular)
            }
            Spacer()
        }
        .background(Color.clear.opacity(0.001))
        .onTapGesture {
            onTap(pin: pin)
        }
    }
    
    func onTap(pin: PinnedItem) {
        if let vocabList = pin.vocabList {
            paths.append(.vocabListDetail(list: vocabList, autoStudy: false))
        } else if let parseList = pin.parsingList {
            paths.append(.parsingListDetail(parseList))
        }
    }
    
    @ViewBuilder
    func RecentActivitySection() -> some View {
        VStack {
            if showFullRecent {
                HStack(alignment: .firstTextBaseline) {
                    Image(systemName: "timer")
                        .matchedGeometryEffect(id: "home.recent.recent-image", in: homeViewNamepace)
                        .font(.headline)
                        .foregroundColor(.appOrange)
                    Text("Recent Activity")
                        .font(.headline)
                        .bold()
                        .transition(.opacity)
                    Spacer()
                    Button(action: {
                        withAnimation {
                            showFullRecent.toggle()
                            UserDefaultKey.homeViewShowFullRecents.set(val: showFullRecent)
                        }
                    }, label: {
                        Image(systemName: "chevron.up")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                    })
                    .matchedGeometryEffect(id: "home.recent.chevron", in: homeViewNamepace)
                }
                Divider()
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(Array(sessions.prefix(8))) { session in
                        RecentActivityRow(session: session)
                    }
                }
                .padding(.top, 8)
            } else {
                HStack {
                    Image(systemName: "timer")
                        .matchedGeometryEffect(id: "home.recent.recent-image", in: homeViewNamepace)
                        .font(.headline)
                        .foregroundColor(.appOrange)
                    HStack(spacing: 14) {
                        ForEach(Array(sessions.prefix(5))) { session in
                            Image(systemName: session.activityType.imageName)
                                .matchedGeometryEffect(id: "session-row.image.\(session.id ?? "")", in: homeViewNamepace)
                                .font(.title2)
                                .foregroundColor(.accentColor)
                        }
                    }
                    Spacer()
                    Button(action: {
                        withAnimation {
                            showFullRecent.toggle()
                            UserDefaultKey.homeViewShowFullRecents.set(val: showFullRecent)
                        }
                    }, label: {
                        Image(systemName: "chevron.down")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                    })
                    .matchedGeometryEffect(id: "home.recent.chevron", in: homeViewNamepace)
                }
            }
        }
        .appCard()
        .padding(.horizontal, Design.viewHorziontalPadding)
    }
        
    @ViewBuilder
    func RecentActivityRow(session: StudySession) -> some View {
        HStack(alignment: .center) {
            Image(systemName: session.activityType.imageName)
                .matchedGeometryEffect(id: "session-row.image.\(session.id ?? "")", in: homeViewNamepace)
                .font(.largeTitle)
                .foregroundColor(.accentColor)
            VStack(alignment: .leading) {
                Text(session.activityType.description)
                    .font(.subheadline)
                    .fontWeight(.regular)
                Text(session.activityTitle ?? "")
                    .font(.caption)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
                    .fontWeight(.regular)
            }
            Spacer()
        }
    }
}

struct NewHomeView_Previews: PreviewProvider {
    static var previews: some View {
        NewHomeView()
    }
}
