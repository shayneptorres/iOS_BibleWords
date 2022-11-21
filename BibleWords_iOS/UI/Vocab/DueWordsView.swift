//
//  DueWordsView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/15/22.
//

import SwiftUI
import Combine
import CoreData

class DueWordsViewModel: ObservableObject, Equatable {
    @Published var isBuilding = true
    let id = UUID().uuidString
    @Published var animationRotationAngle: CGFloat = 0.0
    @Published var timer: Publishers.Autoconnect<Timer.TimerPublisher> = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var wordsAreReady = PassthroughSubject<Void, Never>()
    private var subscribers: [AnyCancellable] = []
    
    init() {
        Task {
            API.main.coreDataReadyPublisher.sink { [weak self] isReady in
                if isReady {
                    self?.wordsAreReady.send()
                }
            }.store(in: &self.subscribers)
        }
        
        wordsAreReady.sink { [weak self] in
            withAnimation {
                DispatchQueue.main.async {
                    self?.timer.upstream.connect().cancel()
                    self?.isBuilding = false
                }
            }
        }.store(in: &subscribers)
        
        timer.sink { [weak self] _ in
            self?.animationRotationAngle += 360
        }.store(in: &subscribers)
    }
    
    static func == (lhs: DueWordsViewModel, rhs: DueWordsViewModel) -> Bool {
        return true
    }
}

struct DueWordsView: View, Equatable {
    enum SoonFilter: CaseIterable {
        case minute30
        case hour1
        case hour3
        case hour6
        case hour12
        case hour24
        
        var title: String {
            switch self {
            case .minute30: return "30min"
            case .hour1: return "1hr"
            case .hour3: return "3hr"
            case .hour6: return "6hr"
            case .hour12: return "12hr"
            case .hour24: return "24hr"
            }
        }
        
        var timeValue: Int {
            switch self {
            case .minute30: return 30.minutes
            case .hour1: return 1.hours
            case .hour3: return 3.hours
            case .hour6: return 6.hours
            case .hour12: return 12.hours
            case .hour24: return 24.hours
            }
        }
    }
    
    @Environment(\.managedObjectContext) var context
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @ObservedObject var viewModel = DueWordsViewModel()
    @State var refreshtimer: Publishers.Autoconnect<Timer.TimerPublisher> = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    @State var langFilter: Language = .all
    @State var showStudyWordsView = false
    @State var dueWords: [VocabWord] = []
    @State var dueSoonWords: [VocabWord] = []
    @State var studyWords: [VocabWord] = []
    @State var soonFilter = SoonFilter.hour1
    @State var showSoonWords = false
    
    static func == (lhs: DueWordsView, rhs: DueWordsView) -> Bool {
        return true
    }
    
    var buttonTitle: String {
        switch langFilter {
        case .hebrew:
            return "Study \(dueWords.filter { ($0.list?.count ?? 0) > 0 && $0.lang == Language.hebrew.rawValue }.count) Hebrew words"
        case .aramaic:
            return ""
        case .greek:
            return "Study \(dueWords.filter { ($0.list?.count ?? 0) > 0 && $0.lang == Language.greek.rawValue }.count) Greek words"
        case .all:
            return "Study All \(dueWords.filter { ($0.list?.count ?? 0) > 0 }.count) words"
        case .custom:
            return "Study Custom \(dueWords.filter { ($0.list?.count ?? 0) > 0 && $0.lang == Language.custom.rawValue  }.count) words"
        }
    }
    
    var body: some View {
        List {
            if viewModel.isBuilding {
                DataIsBuildingCard(rotationAngle: $viewModel.animationRotationAngle)
                    .transition(.move(edge: .trailing))
                    .padding(.horizontal, 12)
            } else {
                HStack {
                    Button(action: { showSoonWords = true }, label: {
                        VStack {
                            Image(systemName: "calendar.badge.clock")
                                .padding(.bottom, 4)
                            Text("Words Due Soon")
                                .bold()
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 80)
                        .background(Color.accentColor)
                        .cornerRadius(12)
                    })
                    Button(action: { showStudyWordsView = true }, label: {
                        VStack {
                            Image(systemName: "brain.head.profile")
                                .padding(.bottom, 4)
                            Text("Study")
                                .bold()
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 80)
                        .background(Color.accentColor)
                        .cornerRadius(12)
                    })
                }
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowBackground(Color.appBackground)
                .foregroundColor(.white)
                .buttonStyle(.borderless)
                Section {
                    DueWordsSection()
                }
            }
        }
        .fullScreenCover(isPresented: $showStudyWordsView) {
            StudyVocabWordsView(vocabList: nil, allWordInfoIds: []) {
                refreshWords()
            }
        }
        .sheet(isPresented: $showSoonWords, content: {
            NavigationStack {
                List {
                    Section {
                        HStack {
                            Text("\(dueSoonWords.count)")
                                .bold()
                                .foregroundColor(.accentColor)
                            Text(" words due in the next")
                            Spacer()
                            Menu(content: {
                                ForEach(SoonFilter.allCases, id: \.title) { filter in
                                    Button(action: {
                                        soonFilter = filter
                                        refreshSoonDueWords()
                                    }, label: {
                                        Text(filter.title)
                                    })
                                }
                            }, label: {
                                Label(soonFilter.title, systemImage: "clock.arrow.circlepath")
                                    .foregroundColor(.accentColor)
                            })
                        }
                    }
                    ForEach(dueSoonWords.sorted { $0.dueDate ?? Date() < $1.dueDate ?? Date() }) { word in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                WordInfoRow(wordInfo: word.wordInfo.bound())
                                Text("Due in \(word.dueDate?.prettyTimeSinceNow ?? "-")")
                                    .bold()
                                    .font(.caption)
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                            }
                            Spacer()
                        }
                    }
                }
                .toolbar {
                    Button(action: {
                        showSoonWords = false
                    }, label: {
                        Text("Dismiss")
                            .bold()
                    })
                }
                .navigationTitle("Words Due Soon")
                .navigationBarTitleDisplayMode(.inline)
            }
        })
        .navigationDestination(for: Bible.WordInfo.self) { word in
            WordInfoDetailsView(word: word.bound())
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItemGroup(placement: .principal) {
                VStack {
                    Text("Your Due Words")
                        .font(.system(size: 17))
                    Text("\(dueWords.count) words")
                        .font(.system(size: 12))
                }
            }
        }
        .onAppear {
            refreshWords()
        }
        .refreshable {
            refreshWords()
        }
        .onReceive(refreshtimer) { _ in
            withAnimation {
                refreshWords()
            }
        }
    }
    
    var filteredDueWords: [VocabWord] {
        switch langFilter {
        case .all:
            return dueWords.filter { ($0.list?.count ?? 0) > 0 }.map { $0 }
        case .greek:
            return dueWords.filter { ($0.list?.count ?? 0) > 0 && $0.lang == Language.greek.rawValue }
        case .hebrew:
            return dueWords.filter { ($0.list?.count ?? 0) > 0 && $0.lang == Language.hebrew.rawValue }
        case .custom:
            return dueWords.filter { ($0.list?.count ?? 0) > 0 && $0.lang == Language.custom.rawValue }
        case .aramaic:
            return []
        }
    }
    
    var filteredDueWordInfos: [Bible.WordInfo] {
        switch langFilter {
        case .all:
            return filteredDueWords.map { $0.wordInfo }
        case .greek:
            return filteredDueWords.map { $0.wordInfo }
        case .hebrew:
            return filteredDueWords.map { $0.wordInfo }
        case .custom:
            return filteredDueWords.map { $0.wordInfo }
        case .aramaic:
            return []
        }
    }
}

extension DueWordsView {
    func onStudyWords() {
        showStudyWordsView = true
    }
    
    func refreshWords() {
        refreshDueWords()
        refreshSoonDueWords()
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
        
        dueWords = fetchedVocabWords.filter { ($0.list?.count ?? 0) > 0 }
    }
    
    func refreshSoonDueWords() {
        let vocabFetchRequest = NSFetchRequest<VocabWord>(entityName: "VocabWord")
        vocabFetchRequest.predicate = NSPredicate(format: "dueDate > %@ AND dueDate < %@ && currentInterval > 0", Date() as CVarArg, Date().addingTimeInterval(TimeInterval(soonFilter.timeValue)) as CVarArg)
        var fetchedVocabWords: [VocabWord] = []
        do {
            fetchedVocabWords = try context.fetch(vocabFetchRequest)
        } catch let err {
            print(err)
        }
        
        dueSoonWords = fetchedVocabWords.filter { ($0.list?.count ?? 0) > 0 }
    }
}

extension DueWordsView {
    
    @ViewBuilder
    func HorizontalLangFilterSection() -> some View {
        HStack {
            Button(action: {
                langFilter = .all
            }, label: {
                VStack {
                    Image(systemName: "sum")
                        .font(.title2)
                        .padding(.bottom, 4)
                    Text("All: \(dueWords.filter { ($0.list?.count ?? 0) > 0 }.count)")
                        .font(.subheadline)
                }
                .foregroundColor(langFilter == .all ? .white : .accentColor)
                .appCard(height: 60, backgroundColor: langFilter == .all ? .accentColor : Color(uiColor: .secondarySystemGroupedBackground))
            })
            Button(action: {
                langFilter = .greek
            }, label: {
                VStack {
                    Text("‎Ω")
                        .font(.bible32)
                    Text("Greek: \(dueWords.filter { ($0.list?.count ?? 0) > 0 && $0.lang == Language.greek.rawValue }.count)")
                        .font(.subheadline)
                }
                .foregroundColor(langFilter == .greek ? .white : .accentColor)
                .appCard(height: 60, backgroundColor: langFilter == .greek ? .accentColor : Color(uiColor: .secondarySystemGroupedBackground))
            })
            Button(action: {
                langFilter = .hebrew
            }, label: {
                VStack {
                    Text("‎א")
                        .font(.bible40)
                    Text("Hebrew: \(dueWords.filter { ($0.list?.count ?? 0) > 0 && $0.lang == Language.hebrew.rawValue }.count)")
                        .font(.subheadline)
                }
                .foregroundColor(langFilter == .hebrew ? .white : .accentColor)
                .appCard(height: 60, backgroundColor: langFilter == .hebrew ? .accentColor : Color(uiColor: .secondarySystemGroupedBackground))
            })
        }
        .padding(.horizontal, 12)
    }
    
    @ViewBuilder
    func VerticalLangFilterSection() -> some View {
        VStack(spacing: 4) {
            Button(action: {
                langFilter = .all
            }, label: {
                VStack {
                    Image(systemName: "sum")
                        .font(.title2)
                        .padding(.bottom, 4)
                    Text("All: \(dueWords.filter { ($0.list?.count ?? 0) > 0 }.count)")
                        .font(.subheadline)
                }
                .foregroundColor(langFilter == .all ? .white : .accentColor)
                .appCard(height: 60, backgroundColor: langFilter == .all ? .accentColor : Color(uiColor: .secondarySystemGroupedBackground))
            })
            Button(action: {
                langFilter = .greek
            }, label: {
                VStack {
                    Text("‎Ω")
                        .font(.bible32)
                    Text("Greek: \(dueWords.filter { ($0.list?.count ?? 0) > 0 && $0.lang == Language.greek.rawValue }.count)")
                        .font(.subheadline)
                }
                .foregroundColor(langFilter == .greek ? .white : .accentColor)
                .appCard(height: 60, backgroundColor: langFilter == .greek ? .accentColor : Color(uiColor: .secondarySystemGroupedBackground))
            })
            Button(action: {
                langFilter = .hebrew
            }, label: {
                VStack {
                    Text("‎א")
                        .font(.bible40)
                    Text("Hebrew: \(dueWords.filter { ($0.list?.count ?? 0) > 0 && $0.lang == Language.hebrew.rawValue }.count)")
                        .font(.subheadline)
                }
                .foregroundColor(langFilter == .hebrew ? .white : .accentColor)
                .appCard(height: 60, backgroundColor: langFilter == .hebrew ? .accentColor : Color(uiColor: .secondarySystemGroupedBackground))
            })
        }
        .padding(.horizontal, 12)
    }
    
    @ViewBuilder
    func DueWordsSection() -> some View {
        ForEach(filteredDueWordInfos.uniqueSorted) { wordInfo in
            NavigationLink(value: AppPath.wordInfo(wordInfo)) {
                WordInfoRow(wordInfo: wordInfo.bound())
            }
        }
    }
}

//struct DueWordsView_Previews: PreviewProvider {
//    static var previews: some View {
//        DueWordsView()
//    }
//}
