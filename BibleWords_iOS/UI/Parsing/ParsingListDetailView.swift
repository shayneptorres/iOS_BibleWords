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
        
        Task {
            API.main.coreDataReadyPublisher.sink { [weak self] isReady in
                if isReady {
                    self?.buildList(range: range)
                }
            }.store(in: &self.subscribers)
        }
        
    }
    
    func buildList(range: VocabWordRange) {
        VocabListBuilder.buildParsingList(range: range.bibleRange,
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
    
    // MARK: Settings State
    @State var showParsingPracticeView = false
    @State var showSettings = false
    @State var isPinned = false
    
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
                        if viewModel.list.language == .greek {
                            GreekSettingsSection()
                        } else {
                            HebrewSettingsSection()
                        }
                        Text("\(viewModel.list.range?.occurrences ?? 0)+ occurrences")
                    }
                    Section {
                        NavigationLink(destination: {
                            ParsingListSessionsView(list: viewModel.list.bound())
                        }, label: {
                            Text("Parsing Sessions Reports")
                        })
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
                    Section {
                        ForEach(groupedParsingInstances.sorted { $0.lemma < $1.lemma }, id: \.lemma) { group in
                            NavigationLink(destination: {
                                List {
                                    Section {
                                        ForEach(group.instances) { instance in
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
                                        Text(group.instances.first?.lemma ?? "").font(.bible24)
                                    }
                                }
                            }) {
                                HStack {
                                    Text(group.lemma)
                                        .font(viewModel.list.language.meduimBibleFont)
                                    Spacer()
                                    Text("\(group.instances.count) forms")
                                        .font(.subheadline)
                                        .foregroundColor(Color(uiColor: .secondaryLabel))
                                }
                            }
                        }
                    } header: {
                        Text("Lexical Forms")
                    } footer: {
                        Spacer().frame(height: 100)
                    }
                }
            }
            VStack {
                Spacer()
                AppButton(text: "Practice Parsing") {
                    showParsingPracticeView = true
                }
                .disabled(viewModel.isBuilding)
                .padding([.horizontal, .bottom])
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showSettings = true
                }, label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                })
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .fullScreenCover(isPresented: $showParsingPracticeView) {
            PracticeParsingView(parsingList: viewModel.list, parsingInstances: viewModel.instances)
        }
        .navigationTitle(viewModel.list.defaultTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension ParsingListDetailView {
    @ViewBuilder
    func SettingsView() -> some View {
        NavigationView {
            ZStack {
                Color
                    .appBackground
                    .ignoresSafeArea()
                ScrollView {
                    VStack {
                        HStack {
                            Text("Pin List")
                            Spacer()
                            Toggle(isOn: $isPinned, label: {})
                                .onChange(of: isPinned) { bool in
                                    CoreDataManager.transaction(context: context) {
                                        if bool && viewModel.list.pin == nil {
                                            
                                            let pin = PinnedItem(context: context)
                                            pin.id = UUID().uuidString
                                            pin.createdAt = Date()
                                            pin.pinTitle = viewModel.list.title
                                            pin.parsingList = viewModel.list
                                        } else if let pin = viewModel.list.pin {
                                            context.delete(pin)
                                        }
                                    }
                                }
                        }
                        .appCard(height: 30)
                        
                    }
                    .padding(12)
                }
            }
            .toolbar {
                Button(action: {
                    showSettings = false
                }, label: {
                    Text("Dismiss")
                        .bold()
                })
            }
            .onAppear {
                isPinned = viewModel.list.pin != nil
            }
        }
    }
}

extension ParsingListDetailView {
    func GreekSettingsSection() -> some View {
        Section {
            if viewModel.list.wordType == .verb {
                VerbTenseRow()
                VerbVoiceRow()
                VerbMoodRow()
                if viewModel.list.wordType == .verb && viewModel.list.moods.contains(.participle) {
                    NounCasesRow()
                    GenderRow()
                    NumberRow()
                } else {
                    PersonRow()
                    NumberRow()
                }
            }
            if viewModel.list.wordType == .noun {
                NounCasesRow()
                GenderRow()
                NumberRow()
            }
        } header: {
            Text("Parsing Settings")
        }
    }
    
    func HebrewSettingsSection() -> some View {
        Section {
            if viewModel.list.wordType == .noun {
                GenderRow()
                PersonRow()
                NumberRow()
            }
            if viewModel.list.wordType == .verb {
                VerbStemRow()
                VerbTypeRow()
                GenderRow()
                PersonRow()
                NumberRow()
            }
        } header: {
            Text("Parsing Settings")
        }
    }
    
    func VerbTenseRow() -> some View {
        HStack {
            Text("Select Verb Tense")
            Spacer()
            Text(viewModel.list.tenses.isEmpty ? "All" : viewModel.list.tenses.map { $0.rawValue }.joined(separator: ", "))
                .font(.footnote)
                .foregroundColor(Color(uiColor: .secondaryLabel))
        }
    }
    
    func VerbVoiceRow() -> some View {
        HStack {
            Text("Select Verb Voice")
            Spacer()
            Text(viewModel.list.voices.isEmpty ? "All" : viewModel.list.voices.map { $0.rawValue }.joined(separator: ", "))
                .font(.footnote)
                .foregroundColor(Color(uiColor: .secondaryLabel))
        }
    }
    
    func VerbMoodRow() -> some View {
        HStack {
            Text("Select Verb Mood")
            Spacer()
            Text(viewModel.list.moods.isEmpty ? "All" : viewModel.list.moods.map { $0.rawValue }.joined(separator: ", "))
                .font(.footnote)
                .foregroundColor(Color(uiColor: .secondaryLabel))
        }
    }

    func VerbStemRow() -> some View {
        HStack {
            Text("Select Verb Stem")
            Spacer()
            Text(viewModel.list.stems.isEmpty ? "All" : viewModel.list.stems.map { $0.rawValue }.joined(separator: ", "))
                .font(.footnote)
                .foregroundColor(Color(uiColor: .secondaryLabel))
        }
    }
    
    func VerbTypeRow() -> some View {
        HStack {
            Text("Select Verb Type")
            Spacer()
            Text(viewModel.list.verbTypes.isEmpty ? "All" : viewModel.list.verbTypes.map { $0.rawValue }.joined(separator: ", "))
                .font(.footnote)
                .foregroundColor(Color(uiColor: .secondaryLabel))
        }
    }
    
    func NounCasesRow() -> some View {
        HStack {
            Text("Select Case")
            Spacer()
            Text(viewModel.list.cases.isEmpty ? "All" : viewModel.list.cases.map { $0.rawValue }.joined(separator: ", "))
                .font(.footnote)
                .foregroundColor(Color(uiColor: .secondaryLabel))
        }
    }
    
    func PersonRow() -> some View {
        HStack {
            Text("Select Person")
            Spacer()
            Text(viewModel.list.persons.isEmpty ? "All" : viewModel.list.persons.map { $0.rawValue }.joined(separator: ", "))
                .font(.footnote)
                .foregroundColor(Color(uiColor: .secondaryLabel))
        }
    }
    
    func GenderRow() -> some View {
        HStack {
            Text("Select Gender")
            Spacer()
            Text(viewModel.list.genders.isEmpty ? "All" : viewModel.list.genders.map { $0.rawValue }.joined(separator: ", "))
                .font(.footnote)
                .foregroundColor(Color(uiColor: .secondaryLabel))
        }
    }
    
    func NumberRow() -> some View {
        HStack {
            Text("Select Number")
            Spacer()
            Text(viewModel.list.numbers.isEmpty ? "All" : viewModel.list.numbers.map { $0.rawValue }.joined(separator: ", "))
                .font(.footnote)
                .foregroundColor(Color(uiColor: .secondaryLabel))
        }
    }
}

struct ParsingListDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ParsingListDetailView(viewModel: .init(list: .init(context: PersistenceController.preview.container.viewContext)))
    }
}

