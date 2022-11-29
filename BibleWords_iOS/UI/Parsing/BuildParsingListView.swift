//
//  BuildParsingListView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/18/22.
//

import SwiftUI
import Combine

struct BuildParsingListView: View {
    enum SettingSelection {
        case none
        case nounCases
        case tenses
        case stems
        case hebVerbTypes
        case voices
        case moods
        case persons
        case genders
        case numbers
        
        var sheetHeight: CGFloat {
            switch self {
            case .none: return 0.0
            case .nounCases: return 200
            case .tenses: return 200
            case .stems: return 425
            case .hebVerbTypes: return 275
            case .voices: return 200
            case .moods: return 200
            case .persons: return 100
            case .genders: return 200
            case .numbers: return 115
            }
        }
    }
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var context
    
    @State var parsingInfos: [Bible.ParsingInfo] = []
    @State var parsingInstances: [Bible.WordInstance] = []
    
    @State var ntRange = BibleRange(bookStart: 40, bookEnd: 66, chapStart: 1, chapEnd: 22, occurrencesTxt: "50")
    @State var otRange = BibleRange(bookStart: 1, bookEnd: 39, chapStart: 1, chapEnd: 3, occurrencesTxt: "100")
    
    @State var wordType = Parsing.WordType.verb
    @State var language = Language.greek
    
    @State var showSettingSelector = false
    @State var showBuildParingInfos = false
    @State var isBuilding = false
    @State var selectorType = SettingSelection.none
    let gridItemLayout: [GridItem] = [.init(.flexible()), .init(.flexible()), .init(.flexible())]
    
    @State var cases: [Parsing.Greek.Case] = []
    @State var tenses: [Parsing.Greek.Tense] = []
    @State var stems: [Parsing.Hebrew.Stem] = []
    @State var verbTypes: [Parsing.Hebrew.VerbType] = []
    @State var voices: [Parsing.Greek.Voice] = []
    @State var moods: [Parsing.Greek.Mood] = []
    @State var persons: [Parsing.Person] = []
    @State var genders: [Parsing.Gender] = []
    @State var numbers: [Parsing.Number] = []
    
    var body: some View {
        ZStack {
            List {
                LanguagePicker()
                Section {
                    if language == .greek {
                        GreekSettingsSection()
                    } else {
                        HebrewSettingsSection()
                    }
                } header: {
                    Text("Parsing Settings")
                }
                Section {
                    if language == .greek {
                        BibleRangePickerView(range: $ntRange)
                    } else {
                        BibleRangePickerView(range: $otRange)
                    }
                } header: {
                    Text("Bible Range")
                } footer: {
                    Spacer().frame(height: 100)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Dismiss")
                        .bold()
                })
            }
            ToolbarItem(placement: .primaryAction) {
                Button(action: onBuild, label: {
                    Text(isBuilding ? "Building list..." : "Build List")
                        .fontWeight(.semibold)
                })
                .labelStyle(.titleAndIcon)
            }
        }
        .sheet(isPresented: .init(get: {selectorType != .none}, set: {_ in})) {
            SettingSelector()
                .onDisappear {
                    selectorType = .none
                }
//                .presentationDetents([.height(selectorType.sheetHeight)])
        }
        .sheet(isPresented: $showBuildParingInfos) {
            BuiltParsingWordsView()
        }
        .navigationTitle("Build Parsing List")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension BuildParsingListView {
    var groupedParsingInstances: [GroupedParsingInstances] {
        let instancesByLemma: [String:[Bible.WordInstance]] = Dictionary(grouping: parsingInstances, by: { $0.lemma })
        return instancesByLemma
            .map { GroupedParsingInstances(lemma: $0.key, instances: $0.value) }
            .sorted { $0.lemma < $1.lemma }
    }
    
    func onBuild() {
        isBuilding = true
        let buildRange = language == .greek ? ntRange : otRange
        Task {
            VocabListBuilder.buildParsingList(range: buildRange,
                                                        language: language,
                                                        wordType: wordType,
                                                        cases: cases,
                                                        genders: genders,
                                                        numbers: numbers,
                                                        tenses: tenses,
                                                        voices: voices,
                                                        moods: moods,
                                                        persons: persons,
                                                        stems: stems,
                                                        verbTypes: verbTypes,
                                                        onComplete: { instances in
                DispatchQueue.main.async {
                    parsingInstances = instances
                    isBuilding = false
                    showBuildParingInfos = true
                }
            })
        }
    }
    
    func onSave() {
        CoreDataManager.transaction(context: context) {
            let parsingList = ParsingList(context: context)
            parsingList.id = UUID().uuidString
            let buildRange = language == .greek ? ntRange : otRange
            parsingList.title = buildRange.title
            parsingList.details = buildRange.details
            parsingList.createdAt = Date()
            
            parsingList.languageInt = language.rawValue
            parsingList.wordTypeStr = wordType.rawValue
            parsingList.casesStr = cases.map { $0.rawValue }.joined(separator: ".")
            parsingList.numbersStr = numbers.map { $0.rawValue }.joined(separator: ".")
            parsingList.gendersStr = genders.map { $0.rawValue }.joined(separator: ".")
            parsingList.tensesStr = tenses.map { $0.rawValue }.joined(separator: ".")
            parsingList.voicesStr = voices.map { $0.rawValue }.joined(separator: ".")
            parsingList.moodsStr = moods.map { $0.rawValue }.joined(separator: ".")
            parsingList.stemsStr = stems.map { $0.rawValue }.joined(separator: ".")
            parsingList.hebVerbTypesStr = verbTypes.map { $0.rawValue }.joined(separator: ".")
            parsingList.range = VocabWordRange.new(context: context, range: buildRange)
            
            showBuildParingInfos = false
            presentationMode.wrappedValue.dismiss()
        }
    }
}

typealias GroupedParsingInstances = (lemma: String, instances: [Bible.WordInstance])
extension BuildParsingListView {
    func BuiltParsingWordsView() -> some View {
        NavigationView {
            ZStack {
                List {
                    HStack {
                        Text("\(groupedParsingInstances.count)")
                            .bold()
                            .foregroundColor(.accentColor)
                        +
                        Text(" words")
                    }
                    HStack {
                        Text("\(parsingInstances.count)")
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
                                    .font(language.meduimBibleFont)
                            }
                            ForEach(group.instances) { instance in
                                VStack(alignment: .leading) {
                                    Text(instance.textSurface)
                                        .font(language.meduimBibleFont)
                                        .padding(.bottom, 4)
                                    Text(instance.parsing)
                                        .font(.subheadline)
                                        .foregroundColor(Color(uiColor: .secondaryLabel))
                                }
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {showBuildParingInfos = false}, label: {Text("Dismiss").bold()})
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: onSave, label: {Text("Save").bold()})
                }
            }
        }
    }
    
    func GreekSettingsSection() -> some View {
        Section {
            WordTypePicker()
            if wordType == .verb {
                VerbTenseRow()
                VerbVoiceRow()
                VerbMoodRow()
                if wordType == .verb && moods.contains(.participle) {
                    NounCasesRow()
                    GenderRow()
                    NumberRow()
                } else {
                    PersonRow()
                    NumberRow()
                }
            }
            if wordType == .noun {
                NounCasesRow()
                GenderRow()
                NumberRow()
            }
        } header: {
            Text("Greek Parsing Settings")
        }
    }
    
    func HebrewSettingsSection() -> some View {
        Section {
            WordTypePicker()
            if wordType == .noun {
                GenderRow()
                PersonRow()
                NumberRow()
            }
            if wordType == .verb {
                VerbStemRow()
                VerbTypeRow()
                GenderRow()
                PersonRow()
                NumberRow()
            }
        } header: {
            Text("Greek Parsing Settings")
        }
    }
}

extension BuildParsingListView {
    func LanguagePicker() -> some View {
        Picker("Language", selection: $language) {
            ForEach([Language.greek, Language.hebrew], id: \.rawValue) { lang in
                Text(lang.title).tag(lang)
            }
        }.animation(.easeInOut, value: language)
    }
    
    func WordTypePicker() -> some View {
        Picker("Word Type", selection: $wordType) {
            ForEach(Parsing.WordType.allCases.dropLast(), id: \.rawValue) { type in
                Text(type.name).tag(type)
            }
        }.animation(.easeInOut, value: wordType)
    }
    
    func VerbTenseRow() -> some View {
        Button(action: {
            selectorType = .tenses
        }, label: {
            HStack {
                Text("Select Verb Tense")
                Spacer()
                Text(tenses.isEmpty ? "All" : tenses.map { $0.rawValue }.joined(separator: ", "))
                    .font(.footnote)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            }
        })
    }
    
    func onTap(tense: Parsing.Greek.Tense) {
        if let index = tenses.firstIndex(of: tense) {
            tenses.remove(at: index)
        } else {
            tenses.append(tense)
        }
    }
    
    func VerbVoiceRow() -> some View {
        Button(action: {
            selectorType = .voices
        }, label: {
            HStack {
                Text("Select Verb Voice")
                Spacer()
                Text(voices.isEmpty ? "All" : voices.map { $0.rawValue }.joined(separator: ", "))
                    .font(.footnote)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            }
        })
    }
    
    func onTap(voice: Parsing.Greek.Voice) {
        if let index = voices.firstIndex(of: voice) {
            voices.remove(at: index)
        } else {
            voices.append(voice)
        }
    }
    
    func VerbMoodRow() -> some View {
        Button(action: {
            selectorType = .moods
        }, label: {
            HStack {
                Text("Select Verb Mood")
                Spacer()
                Text(moods.isEmpty ? "All" : moods.map { $0.rawValue }.joined(separator: ", "))
                    .font(.footnote)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            }
        })
    }
    
    func onTap(mood: Parsing.Greek.Mood) {
        if let index = moods.firstIndex(of: mood) {
            moods.remove(at: index)
        } else {
            moods.append(mood)
        }
    }
    
    func VerbStemRow() -> some View {
        Button(action: {
            selectorType = .stems
        }, label: {
            HStack {
                Text("Select Verb Stem")
                Spacer()
                Text(stems.isEmpty ? "All" : stems.map { $0.rawValue }.joined(separator: ", "))
                    .font(.footnote)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            }
        })
    }
    
    func onTap(stem: Parsing.Hebrew.Stem) {
        if let index = stems.firstIndex(of: stem) {
            stems.remove(at: index)
        } else {
            stems.append(stem)
        }
    }
    
    func VerbTypeRow() -> some View {
        Button(action: {
            selectorType = .hebVerbTypes
        }, label: {
            HStack {
                Text("Select Verb Type")
                Spacer()
                Text(verbTypes.isEmpty ? "All" : verbTypes.map { $0.rawValue }.joined(separator: ", "))
                    .font(.footnote)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            }
        })
    }
    
    func onTap(verbType: Parsing.Hebrew.VerbType) {
        if let index = verbTypes.firstIndex(of: verbType) {
            verbTypes.remove(at: index)
        } else {
            verbTypes.append(verbType)
        }
    }
    
    func NounCasesRow() -> some View {
        Button(action: {
            selectorType = .nounCases
        }, label: {
            HStack {
                Text("Select Case")
                Spacer()
                Text(cases.isEmpty ? "All" : cases.map { $0.rawValue }.joined(separator: ", "))
                    .font(.footnote)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            }
        })
    }
    
    func onTap(caseType: Parsing.Greek.Case) {
        if let index = cases.firstIndex(of: caseType) {
            cases.remove(at: index)
        } else {
            cases.append(caseType)
        }
    }
    
    func PersonRow() -> some View {
        Button(action: {
            selectorType = .persons
        }, label: {
            HStack {
                Text("Select Person")
                Spacer()
                Text(persons.isEmpty ? "All" : persons.map { $0.rawValue }.joined(separator: ", "))
                    .font(.footnote)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            }
        })
    }
    
    func onTap(person: Parsing.Person) {
        if let index = persons.firstIndex(of: person) {
            persons.remove(at: index)
        } else {
            persons.append(person)
        }
    }
    
    func GenderRow() -> some View {
        Button(action: {
            selectorType = .genders
        }, label: {
            HStack {
                Text("Select Gender")
                Spacer()
                Text(genders.isEmpty ? "All" : genders.map { $0.rawValue }.joined(separator: ", "))
                    .font(.footnote)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            }
        })
    }
    
    func onTap(gender: Parsing.Gender) {
        if let index = genders.firstIndex(of: gender) {
            genders.remove(at: index)
        } else {
            genders.append(gender)
        }
    }
    
    func NumberRow() -> some View {
        Button(action: {
            selectorType = .numbers
        }, label: {
            HStack {
                Text("Select Number")
                Spacer()
                Text(numbers.isEmpty ? "All" : numbers.map { $0.rawValue }.joined(separator: ", "))
                    .font(.footnote)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            }
        })
    }
    
    func onTap(number: Parsing.Number) {
        if let index = numbers.firstIndex(of: number) {
            numbers.remove(at: index)
        } else {
            numbers.append(number)
        }
    }
    
}

extension BuildParsingListView {
    func SettingSelector() -> some View {
        switch selectorType {
        case .tenses:
            return AnyView(
                LazyVGrid(columns: gridItemLayout, spacing: 8) {
                    ForEach(Parsing.Greek.Tense.allCases, id: \.rawValue) { tense in
                        VStack {
                            Text(tense.rawValue)
                                .frame(maxWidth: .infinity, minHeight: 45)
                                .padding(12)
                                .background(tenses.contains(tense) ? Color.accentColor : Color(UIColor.quaternaryLabel))
                                .cornerRadius(Design.defaultCornerRadius)
                        }
                        .onTapGesture {
                            onTap(tense: tense)
                        }
                    }
                }
                .padding(.horizontal)
            )
        case .voices:
            return AnyView(
                LazyVGrid(columns: gridItemLayout, spacing: 8) {
                    ForEach(Parsing.Greek.Voice.allCases, id: \.rawValue) { voice in
                        VStack {
                            Text(voice.rawValue)
                                .frame(maxWidth: .infinity, minHeight: 45)
                                .padding(12)
                                .background(voices.contains(voice) ? Color.accentColor : Color(UIColor.quaternaryLabel))
                                .cornerRadius(Design.defaultCornerRadius)
                        }
                        .onTapGesture {
                            onTap(voice: voice)
                        }
                    }
                }
                .padding(.horizontal)
            )
        case .moods:
            return AnyView(
                LazyVGrid(columns: gridItemLayout, spacing: 8) {
                    ForEach(Parsing.Greek.Mood.allCases, id: \.rawValue) { mood in
                        VStack {
                            Text(mood.rawValue)
                                .frame(maxWidth: .infinity, minHeight: 45)
                                .padding(12)
                                .background(moods.contains(mood) ? Color.accentColor : Color(UIColor.quaternaryLabel))
                                .cornerRadius(Design.defaultCornerRadius)
                        }
                        .onTapGesture {
                            onTap(mood: mood)
                        }
                    }
                }
                .padding(.horizontal)
            )
        case .stems:
            return AnyView(
                LazyVGrid(columns: gridItemLayout, spacing: 8) {
                    ForEach(Parsing.Hebrew.Stem.allCases, id: \.rawValue) { stem in
                        VStack {
                            Text(stem.rawValue)
                                .frame(maxWidth: .infinity, minHeight: 45)
                                .padding(12)
                                .background(stems.contains(stem) ? Color.accentColor : Color(UIColor.quaternaryLabel))
                                .cornerRadius(Design.defaultCornerRadius)
                        }
                        .onTapGesture {
                            onTap(stem: stem)
                        }
                    }
                }
                .padding(.horizontal)
            )
        case .hebVerbTypes:
            return AnyView(
                LazyVGrid(columns: gridItemLayout, spacing: 8) {
                    ForEach(Parsing.Hebrew.VerbType.allCases, id: \.rawValue) { vType in
                        VStack {
                            Text(vType.rawValue)
                                .frame(maxWidth: .infinity, minHeight: 45)
                                .padding(12)
                                .background(verbTypes.contains(vType) ? Color.accentColor : Color(UIColor.quaternaryLabel))
                                .cornerRadius(Design.defaultCornerRadius)
                        }
                        .onTapGesture {
                            onTap(verbType: vType)
                        }
                    }
                }
                .padding(.horizontal)
            )
        case .persons:
            return AnyView(
                LazyVGrid(columns: gridItemLayout, spacing: 8) {
                    ForEach(Parsing.Person.allCases, id: \.rawValue) { person in
                        VStack {
                            Text(person.rawValue)
                                .frame(maxWidth: .infinity, minHeight: 45)
                                .padding(12)
                                .background(persons.contains(person) ? Color.accentColor : Color(UIColor.quaternaryLabel))
                                .cornerRadius(Design.defaultCornerRadius)
                        }
                        .onTapGesture {
                            onTap(person: person)
                        }
                    }
                }
                .padding(.horizontal)
            )
        case .nounCases:
            return AnyView(
                LazyVGrid(columns: gridItemLayout, spacing: 8) {
                    ForEach(Parsing.Greek.Case.allCases, id: \.rawValue) { caseType in
                        VStack {
                            Text(caseType.rawValue)
                                .frame(maxWidth: .infinity, minHeight: 45)
                                .padding(12)
                                .background(cases.contains(caseType) ? Color.accentColor : Color(UIColor.quaternaryLabel))
                                .cornerRadius(Design.defaultCornerRadius)
                        }
                        .onTapGesture {
                            onTap(caseType: caseType)
                        }
                    }
                }
                .padding(.horizontal)
            )
        case .genders:
            return AnyView(
                LazyVGrid(columns: gridItemLayout, spacing: 8) {
                    ForEach(Parsing.Gender.allCases, id: \.rawValue) { gender in
                        VStack {
                            Text(gender.rawValue)
                                .frame(maxWidth: .infinity, minHeight: 45)
                                .padding(12)
                                .background(genders.contains(gender) ? Color.accentColor : Color(UIColor.quaternaryLabel))
                                .cornerRadius(Design.defaultCornerRadius)
                        }
                        .onTapGesture {
                            onTap(gender: gender)
                        }
                    }
                }
                .padding(.horizontal)
            )
        case .numbers:
            return AnyView(
                LazyVGrid(columns: gridItemLayout, spacing: 8) {
                    ForEach(Parsing.Number.allCases, id: \.rawValue) { number in
                        VStack {
                            Text(number.rawValue)
                                .frame(maxWidth: .infinity, minHeight: 45)
                                .padding(12)
                                .background(numbers.contains(number) ? Color.accentColor : Color(UIColor.quaternaryLabel))
                                .cornerRadius(Design.defaultCornerRadius)
                        }
                        .onTapGesture {
                            onTap(number: number)
                        }
                    }
                }
                .padding(.horizontal)
            )
        default:
            return AnyView(
                Text("TBD")
            )
        }
    }
}

struct BuildParsingListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BuildParsingListView()
        }
    }
}
