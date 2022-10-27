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
    @Published var dueList: VocabWordList
    let id = UUID().uuidString
    @Published var animationRotationAngle: CGFloat = 0.0
    @Published var timer: Publishers.Autoconnect<Timer.TimerPublisher> = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private var subscribers: [AnyCancellable] = []
    
    init(list: VocabWordList) {
        self.dueList = list
        Task {
            API.main.coreDataReadyPublisher.sink { [weak self] isReady in
                if isReady {
                    withAnimation {
                        self?.timer.upstream.connect().cancel()
                        self?.isBuilding = false
                    }
                }
            }.store(in: &self.subscribers)
        }
        
        timer.sink { [weak self] _ in
            self?.animationRotationAngle += 360
        }.store(in: &subscribers)
    }
    
    static func == (lhs: DueWordsViewModel, rhs: DueWordsViewModel) -> Bool {
        return lhs.dueList.id == rhs.dueList.id
    }
}

struct DueWordsView: View, Equatable {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \VocabWord.dueDate, ascending: false)],
        predicate: NSPredicate(format: "dueDate <= %@ && currentInterval > 0", Date() as CVarArg)
    ) var dueWords: FetchedResults<VocabWord>
    @Environment(\.managedObjectContext) var context
    
    @ObservedObject var viewModel: DueWordsViewModel
    @State var langFilter: Language = .all
    @State var showStudyWordsView = false
    @State var studyWords: [VocabWord] = []
    
    static func == (lhs: DueWordsView, rhs: DueWordsView) -> Bool {
        lhs.viewModel.dueList.id == rhs.viewModel.dueList.id
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
        }
    }
    
    var body: some View {
        ZStack {
            Color
                .appBackground
                .ignoresSafeArea()
            ScrollView {
                if viewModel.isBuilding {
                    DataIsBuildingCard(rotationAngle: $viewModel.animationRotationAngle)
                        .transition(.move(edge: .trailing))
                        .padding(.horizontal, 12)
                } else {
                    LangFilterSection()
                    DueWordsSection()
                }
            }
            VStack {
                Spacer()
                AppButton(text: buttonTitle, action: onStudyWords)
                    .padding([.horizontal, .bottom])
                .disabled(viewModel.isBuilding)
            }
        }
        .fullScreenCover(isPresented: $showStudyWordsView) {
            if #available(iOS 16.1, *) {
                VocabListStudyView(vocabList: $viewModel.dueList, allWordInfoIds: [])
            } else {
                VocabListStudyView(vocabList: $viewModel.dueList, allWordInfoIds: [])
            }
        }
        .navigationDestination(for: Bible.WordInfo.self) { word in
            WordInfoDetailsView(word: word)
        }
        .navigationTitle("Your Due Words")
    }
    
    var filteredDueWords: [VocabWord] {
        switch langFilter {
        case .all:
            return dueWords.filter { ($0.list?.count ?? 0) > 0 }.map { $0 }
        case .greek:
            return dueWords.filter { ($0.list?.count ?? 0) > 0 && $0.lang == Language.greek.rawValue }
        case .hebrew:
            return dueWords.filter { ($0.list?.count ?? 0) > 0 && $0.lang == Language.hebrew.rawValue }
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
        case .aramaic:
            return []
        }
    }
}

extension DueWordsView {
    func onStudyWords() {
        CoreDataManager.transaction(context: context) {
            viewModel.dueList.title = "Your Due Words"
        }
        for word in (viewModel.dueList.wordsArr) {
            viewModel.dueList.removeFromWords(word)
        }
        
        for word in filteredDueWords {
            viewModel.dueList.addToWords(word)
        }
        
        showStudyWordsView = true
    }
}

extension DueWordsView {
    
    @ViewBuilder
    func LangFilterSection() -> some View {
        HStack {
            Button(action: {
                langFilter = .all
            }, label: {
                VStack {
                    Image(systemName: "sum")
                        .font(.title2)
                        .padding(.bottom, 4)
                    Text("All: \(dueWords.filter { ($0.list?.count ?? 0) > 0 }.count)")
                        .font(.footnote)
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
                        .font(.footnote)
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
                        .font(.footnote)
                }
                .foregroundColor(langFilter == .hebrew ? .white : .accentColor)
                .appCard(height: 60, backgroundColor: langFilter == .hebrew ? .accentColor : Color(uiColor: .secondarySystemGroupedBackground))
            })
        }
        .padding(.horizontal, 12)
    }
    
    @ViewBuilder
    func DueWordsSection() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(filteredDueWordInfos.uniqueSorted) { wordInfo in
                NavigationLink(value: AppPath.wordInfo(wordInfo)) {
                    HStack {
                        WordInfoRow(wordInfo: wordInfo.bound())
                        Spacer()
                        Image(systemName: "arrow.forward.circle")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                    }
                    .appCard()
                }
            }
        }
        .padding(.horizontal, 12)
    }
}

//struct DueWordsView_Previews: PreviewProvider {
//    static var previews: some View {
//        DueWordsView()
//    }
//}
