//
//  ParsingListDetailView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/20/22.
//

import SwiftUI
import Combine

class ParsingListDetailViewModel: ObservableObject, Equatable {
    @Published var list: ParsingList
    @Published var isBuilding = true
    @Published var instances: [Bible.WordInstance] = []
    var instancesAreReady = CurrentValueSubject<[Bible.WordInstance], Never>([])
    private var subscribers: [AnyCancellable] = []
    
    static func == (lhs: ParsingListDetailViewModel, rhs: ParsingListDetailViewModel) -> Bool {
        return (lhs.list.id ?? "") == (rhs.list.id ?? "")
    }
    
    init(list: ParsingList) {
        self.list = list
        
        guard let range = list.range else { return }
        
        API.main.coreDataReadyPublisher.sink { isReady in
            if isReady {
                Task {
                    await self.buildList(range: range)
                }
            }
        }.store(in: &self.subscribers)
    }
    
    func buildList(range: VocabWordRange) async {
        await VocabListBuilder.buildParsingList(range: range.bibleRange,
                                                language: list.language,
                                                wordType: list.wordType,
                                                cases: list.cases,
                                                genders: list.genders,
                                                numbers: list.numbers,
                                                tenses: list.tenses,
                                                voices: list.voices,
                                                moods: list.moods,
                                                persons: list.persons,
                                                stems: list.stems,
                                                verbTypes: list.verbTypes,
                                                onComplete: { builtInstances in
            
            DispatchQueue.main.async { [weak self] in
                self?.instances = builtInstances
                self?.isBuilding = false
            }
        })
    }
}

struct ParsingListDetailView: View {
    @Environment(\.managedObjectContext) var context
    @ObservedObject var viewModel: ParsingListDetailViewModel
    
    @State var showParsingPracticeView = false
    @State var showListSettings = false
    
    var groupedParsingInstances: [GroupedParsingInstances] {
        let instancesByLemma: [String:[Bible.WordInstance]] = Dictionary(grouping: viewModel.instances, by: { $0.lemma })
        return instancesByLemma
            .map { GroupedParsingInstances(lemma: $0.key, instances: $0.value) }
            .sorted { $0.lemma < $1.lemma }
    }
    
    var body: some View {
        ZStack {
            List {
                if viewModel.isBuilding {
                    DataLoadingRow(text: "Building parsing info...")
                } else {
                    Section {
                        NavigationLink(value: Paths.parsingSessionsList(viewModel.list)) {
                            Text("Parsing Sessions Reports")
                        }
                        .navigationViewStyle(.stack)
                    }
                    HStack {
                        Text("\(groupedParsingInstances.count)")
                            .bold()
                            .foregroundColor(.accentColor)
                        +
                        Text(" words")
                    }
                    HStack {
                        Text("\(viewModel.instances.count)")
                            .bold()
                            .foregroundColor(.accentColor)
                        +
                        Text(" forms")
                    }
                    ForEach(groupedParsingInstances, id: \.lemma) { group in
                        Section {
                            HStack {
                                Text("Lexical Form:")
                                    .bold()
                                Text(group.lemma)
                                    .font(viewModel.list.language.meduimBibleFont)
                            }
                            ForEach(group.instances) { instance in
                                VStack(alignment: .leading) {
                                    Text(instance.textSurface)
                                        .font(viewModel.list.language.meduimBibleFont)
                                        .padding(.bottom, 4)
                                    Text(instance.parsingStr)
                                        .font(.subheadline)
                                        .foregroundColor(Color(uiColor: .secondaryLabel))
                                }
                            }
                        }
                    }
                }
            }
            VStack {
                Spacer()
                AppButton(text: "Practice Parsing") {
                    showParsingPracticeView = true
                }.disabled(viewModel.isBuilding)
            }
        }
        .fullScreenCover(isPresented: $showParsingPracticeView) {
            PracticeParsingView(parsingList: viewModel.list, parsingInstances: viewModel.instances)
        }
        .navigationTitle(viewModel.list.defaultTitle)
    }
}

struct ParsingListDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ParsingListDetailView(viewModel: .init(list: .init(context: PersistenceController.preview.container.viewContext)))
    }
}
